defmodule Proposal do

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
				:actual]

end