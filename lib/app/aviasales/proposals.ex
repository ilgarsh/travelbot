defmodule Proposal do

	@base_url "https://search.aviasales.ru/"

	@derive [Poison.Encoder]
	defstruct [:show_to_affiliates,
				:trip_class,
				:origin,
				:destination,
				:depart_date,
				:return_date,
				:number_of_changes,
				:value,
				:found_at,
				:distance,
				:actual,
				:url]

	def build_aviasales_url(proposal) do
		url = @base_url <> "?" 
		<> "origin_iata=" <> proposal.origin <> "&" 
		<> "destination_iata=" <> proposal.destination <> "&" 
		<> "depart_date=" <> proposal.depart_date <> "&" 
		<> "return_date=" <> proposal.return_date 
		<> "&adults=1&children=0&infants=0&trip_class=0&with_request=true"
		%Proposal{show_to_affiliates: proposal.show_to_affiliates,
							trip_class: proposal.trip_class,
							origin: proposal.origin,
							destination: proposal.destination,
							depart_date: proposal.depart_date,
							return_date: proposal.return_date,
							number_of_changes: proposal.number_of_changes,
							value: proposal.value,
							found_at: proposal.found_at,
							distance: proposal.distance,
							actual: proposal.actual,
							url: url}
	end

end