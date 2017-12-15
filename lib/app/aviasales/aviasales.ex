defmodule Aviasales do

  @token "70bbc8ece8117bb1e230fc89ae60e319"
  @base_url "http://api.travelpayouts.com/v2/prices/latest"

  def build_url(origin, destination, beginning_of_period,
                  limit, trip_duration) do
    @base_url <> "?"
      <> if(origin != "", do: "origin=" <> origin <> "&", else: "")
      <> if(destination != "", do: "destination=" <> destination <> "&", else: "")
      <> if(beginning_of_period != "", do: "beginning_of_period=" <> beginning_of_period <> "&period_type=month&",
                                        else: "period_type=year&")
      <> if(limit != "", do: "limit=" <> limit <> "&", else: "limit=1000&")
      <> if(trip_duration != "", do: "trip_duration=" <> trip_duration <> "&", else: "")
      <> "token=" <> @token <> "&"
      <> "currency=usd"
  end

  def get_proposals(origin, destination, month, money, user_id) do
    year_month = if(month != "", do: month |> convert_month, else: "")
    year_month = (if year_month == "", do: "", else: year_month <> "-01")
    limit = (if money != "", do: "", else: "1000")
    [origin, destination, year_month, limit] |> IO.inspect
    {:ok, response} = build_url(origin, destination, year_month, limit, "") 
      |> HTTPoison.get

    proposals = Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"]

    if money != "", do: proposals = proposals |> Enum.filter(fn prop -> prop.value < String.to_integer(money) end)

    proposals |> Enum.map(fn prop -> Proposal.build_aviasales_URL(prop) end)
  end

  def convert_month(month) do
    month =
    case String.downcase(month) do
      "january" -> 1
      "february" -> 2
      "march" -> 3
        "april" -> 4
        "may" -> 5
        "june" -> 6
        "july" -> 7
        "august" -> 8
        "september" -> 9
        "october" -> 10
        "november" -> 11
        "december" -> 12
    end
    year = if(month > Date.utc_today().month, do: Date.utc_today().year + 1, else: Date.utc_today().year) |> to_string
    month = month |> to_string
    if String.length(month) == 1 do
      year <> "-0" <> month
    else
      year <> "-" <> month
    end
  end

end
