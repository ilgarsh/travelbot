defmodule Proposal do

	@derive [Poison.Encoder]
	defstruct [:show_to_affiliates,
				:trip_class,
				:destination,
				:depart_date,
				:return_date,
				:number_of_changes,
				:value,
				:created_at,
				:ttl,
				:distance,
				:actual]

end