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
      <> if(limit != "", do: "limit=" <> limit <> "&", else: "limit=10&")
      <> if(trip_duration != "", do: "trip_duration=" <> trip_duration <> "&", else: "")
      <> "token=" <> @token <> "&"
      <> "currency=usd"
  end

  def get_proposals(origin, destination, year_month, money) do
    year_month = (if year_month == "", do: "", else: year_month <> "-01")
    limit = (if money != "", do: "", else: "1000")
    {:ok, response} = build_url(origin, destination, year_month, limit, "") 
      |> HTTPoison.get

    proposals = Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"]

    if money != "", do: proposals = proposals |> Enum.filter(fn prop -> prop.value < money end)

    proposals |> Enum.map(fn prop -> Proposal.build_aviasales_URL(prop) end)
  end

end
