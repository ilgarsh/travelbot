defmodule App.Commands do
  use App.Router
  use App.Commander

  require Ecto.Query

  require Grouper
  alias App.Commands.Outside

  # You can create commands in the format `/command` by
  # using the macro `command "command"`.
  command ["hello", "hi"] do
    # Logger module injected from App.Commander
    Logger.log :info, "Command /hello or /hi"

    # You can use almost any function from the Nadia core without
    # having to specify the current chat ID as you can see below.
    # For example, `Nadia.send_message/3` takes as first argument
    # the ID of the chat you want to send this message. Using the
    # macro `send_message/2` defined at App.Commander, it is
    # injected the proper ID at the function. Go take a look.
    #
    # See also: https://hexdocs.pm/nadia/Nadia.html
    send_message "Hello World!"
  end

  command "start" do
    Logger.log :info, "Command /start"
    send_message "Hello! This is the Travel bot. I'll help you decide where to go.\nTell me, where are you?"
    App.Dialog.add_user(update.message.from.id)
    App.Dialog.set_dialog_progress(update.message.from.id, :city)
  end

  command "test" do
    city_code = App.Dialog.get_user_city(update.message.from.id)
    city = city_code |> App.Cities.get_city_name
    proposals = city_code |> Aviasales.get_proposals("", "", "50")
    Enum.reduce(proposals, "", fn x, acc -> acc <> "From #{city} to #{App.Cities.get_city_name(x.destination)}\n#{x.depart_date} - #{x.return_date}\nTickets from #{x.value} RUB: #{x.url}\n\n" end)
    |> send_message
  end

  command "db" do
    (Ecto.Query.from w in "tags", select: w.name) |> App.Repo.all |> Enum.reduce("", fn x, acc -> "#{acc}#{x}\t" end) |> send_message
  end

  command "reset" do
    Logger.log :info, "Command /reset"

    send_message "Let's start over. Where are you?"
    App.Dialog.set_dialog_progress(update.message.from.id, :city)
  end

  # You may split code to other modules using the syntax
  # "Module, :function" instead od "do..end"
  command "outside", Outside, :outside
  # For the sake of this tutorial, I'll define everything here

  command "question" do
    Logger.log :info, "Command /question"

    {:ok, _} = send_message "What's the best JoJo?",
      # Nadia.Model is aliased from App.Commander
      #
      # See also: https://hexdocs.pm/nadia/Nadia.Model.InlineKeyboardMarkup.html
      reply_markup: %Model.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %{
              callback_data: "/choose joseph",
              text: "Joseph Joestar",
            },
            %{
              callback_data: "/choose joseph-of-course",
              text: "Joseph Joestar of course",
            },
          ],
          [
            # Read about fallbacks in the end of the file
            %{
              callback_data: "/typo-:p",
              text: "Other",
            },
          ]
        ]
      }
  end

  # You can create command interfaces for callback querys using this macro.
  callback_query_command "choose" do
    Logger.log :info, "Callback Query Command /choose"

    case update.callback_query.data do
      "/choose joseph" ->
        answer_callback_query text: "Indeed you have good taste."
      "/choose joseph-of-course" ->
        answer_callback_query text: "I can't agree more."
    end
  end

  # You may also want make commands when in inline mode.
  # Be sure to enable inline mode first: https://core.telegram.org/bots/inline
  # Try by typping "@your_bot_name /what-is something"
  inline_query_command "what-is" do
    Logger.log :info, "Inline Query Command /what-is"

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "10 Hours What is Love Jim Carrey HD",
        thumb_url: "https://img.youtube.com/vi/ER97mPHhgtM/3.jpg",
        description: "Have a great time",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=ER97mPHhgtM",
        }
      }
    ]
  end

  # Advanced Stuff
  #
  # Now that you already know basically how this boilerplate works let me
  # introduce you to a cool feature that happens under the hood.
  #
  # If you are used to telegram bot API, you should know that there's more
  # than one path to fetch the current message chat ID so you could answer it.
  # With that in mind and backed upon the neat macro system and the cool
  # pattern matching of Elixir, this boilerplate automatically detectes whether
  # the current message is a `inline_query`, `callback_query` or a plain chat
  # `message` and handles the current case of the Nadia method you're trying to
  # use.
  #
  # If you search for `defmacro send_message` at App.Commander, you'll see an
  # example of what I'm talking about. It just works! It basically means:
  # When you are with a callback query message, when you use `send_message` it
  # will know exatcly where to find it's chat ID. Same goes for the other kinds.

  inline_query_command "foo" do
    Logger.log :info, "Inline Query Command /foo"
    # Where do you think the message will go for?
    # If you answered that it goes to the user private chat with this bot,
    # you're right. Since inline querys can't receive nothing other than
    # Nadia.InlineQueryResult models. Telegram bot API could be tricky.
    send_message "This came from an inline query"
  end

  # Fallbacks

  # Rescues any unmatched callback query.
  callback_query do
    Logger.log :warn, "Did not match any callback query"

    answer_callback_query text: "Sorry, but there is no JoJo better than Joseph."
  end

  # Rescues any unmatched inline query.
  inline_query do
    Logger.log :warn, "Did not match any inline query"

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "Darude-Sandstorm Non non Biyori Renge Miyauchi Cover 1 Hour",
        thumb_url: "https://img.youtube.com/vi/yZi89iQ11eM/3.jpg",
        description: "Did you mean Darude Sandstorm?",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=yZi89iQ11eM",
        }
      }
    ]
  end

  message(text) do
    user_id = update.message.from.id
    Logger.log :info, "Matched message #{text}\nCurrent dialog progress for user #{user_id}: #{App.Dialog.get_user_progress(user_id)}"
    
    case App.Dialog.get_user_progress(user_id) do
      :city -> code = App.Cities.get_city_code(text)
               if is_nil(code) do
                send_message("There is no such city, try again")
               else
                App.Dialog.set_user_city(user_id, code)
                App.Dialog.set_dialog_progress(user_id, :price)
                send_message("Price limit? (in USD, if not, say no)")
               end
      :price -> cond do
                  Grouper.is_numeric(text) ->
                    App.Dialog.set_user_price(user_id, text)
                    App.Dialog.set_dialog_progress(user_id, :month)
                    send_message("You have a preferred travel month? (if not, say no)")
                  String.downcase(text) == "no" ->
                    App.Dialog.set_dialog_progress(user_id, :month)
                    send_message("You have a preferred travel month? (if not, say no)")
                  true ->
                    send_message("Incorrect price, try again")
                end
      :month -> cond do
                  Grouper.is_month(text) ->
                    App.Dialog.set_user_month(user_id, text)
                    App.Dialog.set_dialog_progress(user_id, :destination)
                    send_message("Any preferred travel destination? (if not, say no)")
                  String.downcase(text) == "no" ->
                    App.Dialog.set_dialog_progress(user_id, :destination)
                    send_message("Any preferred travel destination? (if not, say no)")
                  true -> 
                    send_message("There is no such month, try again or say no")
                end
      :destination -> code = App.Cities.get_city_code(text)
                      cond do
                        String.downcase(text) == "no" ->
                          App.Dialog.set_dialog_progress(user_id, :tags)
                          tags = (Ecto.Query.from w in "tags", select: w.name) |> App.Repo.all
                          send_message("Any preferred tags?\nAvaliable tags:\n#{tags |> Enum.join(", ")}\nIf not, say no")
                        is_nil(code) ->
                          send_message("There is no such city, try again or say no")
                        true -> 
                          App.Dialog.set_user_destination(user_id, text)
                          App.Dialog.set_dialog_progress(user_id, :tags)
                          tags = (Ecto.Query.from w in "tags", select: w.name) |> App.Repo.all
                          send_message("Any preferred tags?\nAvaliable tags:\n#{tags |> Enum.join(", ")}\nIf not, say no")
                      end
      :tags -> user_tags = String.split(String.downcase(text), ~r{[(, ), ]})
               cond do
                String.downcase(text) == "no" ->
                   Enum.each(App.Dialog.result_proposals(user_id), fn x -> "From #{App.Dialog.get_user_city(user_id) |> App.Cities.get_city_name} to #{App.Cities.get_city_name(x.destination)}\n#{x.depart_date} - #{x.return_date}\nTickets from #{x.value} USD: #{x.url}\n\n" |>
                    send_message end)
                 user_tags -- ((Ecto.Query.from w in "tags", select: w.name) |> App.Repo.all) == [] -> 
                   App.Dialog.set_user_tags(user_id, user_tags)
                   Enum.each(App.Dialog.result_proposals(user_id), fn x -> "From #{App.Dialog.get_user_city(user_id) |> App.Cities.get_city_name} to #{App.Cities.get_city_name(x.destination)}\n#{x.depart_date} - #{x.return_date}\nTickets from #{x.value} USD: #{x.url}\n\n" |>
                    send_message end)
                 true ->
                   send_message("There are no such tags, try again or say no")
               end

      #:result -> proposals = Aviasales.get_proposals("", "", "50")
    #Enum.reduce(proposals, "", fn x, acc -> acc <> "From #{city} to #{App.Cities.get_city_name(x.destination)}\n#{x.depart_date} - #{x.return_date}\nTickets from #{x.value} RUB: #{x.url}\n\n" end)
    #|> send_message
    end
  end
end
