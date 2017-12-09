defmodule City do

	@derive[Poison.Encoder]
	defstruct [:code,
				:name,
				:country_code]
end