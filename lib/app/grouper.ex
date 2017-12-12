defmodule Grouper do

  def is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _          -> false
    end
  end

  def is_month(str) do
  	Enum.member?([
  		"january",
  	 	"february",
  	 	"march",
  	  	"april",
  	  	"may",
  	  	"june",
  	  	"july",
  	  	"august",
  	  	"september",
  	  	"october",
  	  	"november",
  	  	"december"
  	], str |> String.downcase)
  end

end