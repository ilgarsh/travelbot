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
      <> "token=" <> @token
  end

  def get_top_proposals(origin) do
    {:ok, response} = build_url(origin, "", "", "10", "") |> HTTPoison.get
    Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"]
  end

  def get_min_money_proposals(origin, money) do
    {:ok, response} = build_url(origin, "", "", "1000", "") |> HTTPoison.get
    Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"] |>
    Enum.filter(fn prop -> prop.value < money end)
  end

  def get_proposals_to(origin, destination) do
    {:ok, response} = build_url(origin, destination, "", "10", "") |> HTTPoison.get
    Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"]
  end

  def get_proposals_in(origin, month) do
    {:ok, response} = build_url(origin, "", "2017-" <> month <> "-01", "10", "") |> HTTPoison.get
    Poison.decode!(response.body, as: %{"data" => [%Proposal{}]})["data"]
  end

end
