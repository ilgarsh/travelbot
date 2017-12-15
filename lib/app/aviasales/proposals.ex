defmodule Proposal do
	@base_url "http://trvlbot.herokuapp.com/"

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
	def build_aviasales_URL(proposal) do
		url = @base_url <> "?" 
		<> "origin=" <> proposal.origin <> "&" 
		<> "destination=" <> proposal.destination <> "&" 
		<> "depart=" <> proposal.depart_date <> "&" 
		<> "return=" <> proposal.return_date# <> "tag_id=#{Enum.at(Enum.at(id.rows, 0), 0)}"
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