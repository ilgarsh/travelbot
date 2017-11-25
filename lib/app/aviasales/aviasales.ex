defmodule Aviasales do
  alias Proposal

  @base_url "http://map.aviasales.ru/prices.json"

  def build_url(origin_iata, date, period, direct, min_trip_duration_in_days, max_trip_duration_in_days) do
    @base_url <> "?"
     <> "origin_iata=" <> origin_iata <> "&"
     <> "period=" <> date <> "&"
     <> ":" <> period <> "&"
     <> "direct=" <> direct <> "&" 
     <> "&locale=ru&"
     <> "min_trip_duration_in_days=" <> min_trip_duration_in_days <> "&"
     <> "max_trip_duration_in_days=" <> max_trip_duration_in_days
  end

  def get_proposals(origin_iata, date, period, direct, min_trip_duration_in_days, max_trip_duration_in_days) do
    {:ok, response} = build_url(origin_iata, date, period, direct, 
                          min_trip_duration_in_days, max_trip_duration_in_days) |>
                      HTTPoison.get
    Poison.decode!(response.body, as: [%Proposal{}]) |>
    Enum.sort_by(&(&1.value))
  end

end
