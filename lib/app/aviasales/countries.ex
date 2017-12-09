defmodule Country do
	
	@derive[Poison.Encoder]
	defstruct [:code,
				:name,
				:currency]

end