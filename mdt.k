module MDT-SYNTAX

	/*
	 * TM states 
	 */
	syntax States ::= List{Int, ","}

	/*
	 * TM Final state declaration
	 */
	syntax FinalState ::= "Final" ":" Int
	
	/*
	 * TM Initial state declaration
	 */
	syntax InitialState ::= "Initial" ":" Int

	syntax Movement ::= "L" | "R" | "-"

	/*
	 * TM Transitions declaration
	 */
	syntax Transition ::= "(" Int "," String "," Int "," String "," Movement ")"
						|	Transition Transition [left]

	/*
	 * Initial tape declaration
	 */
	syntax InitialTape ::= List{String, ","}

	syntax Program ::= States FinalState InitialState Transition InitialTape

endmodule


module MDT
	imports MDT-SYNTAX

	/*
	 * transitions-configuration map key
	 */
	syntax K ::= "(" Int "," String ")"
	
	/*
	 * transitions-configuration map value
	 */
	syntax K ::= "(" Int "," String "," Movement ")"

	configuration 
	<T>
		<k> $PGM:Program </k>
		<tape> .Map </tape>
		<current-state> 0 </current-state>
		<current-position> 0 </current-position>
		<transitions> .Map </transitions>
		<states> .Set </states>
		<final-state> 0 </final-state>
		<initial-state> 0 </initial-state>
	</T>

	rule SI:States F:FinalState I:InitialState TT:Transition Tape:InitialTape 
		=> SI ~> F ~> I ~> TT ~> Tape [structural]

	rule T1:Transition T2:Transition => T1 ~> T2 [structural]

	rule <k> ( Q:Int, Qs:States => Qs ) ... </k>
		 <states> S:Set => S SetItem(Q) </states> 
		 when notBool(Q in S)
	rule <k> ( .States => .K ) ... </k>

	/*
	 * Set the given final state and check its declaration.
	 */
	rule <k> ( Final: Q:Int => .K ) ... </k>
		<final-state> FinalState:Int => Q </final-state>
		<states> S:Set </states>
			when Q in S

	/*
	 * Set the given initial state and check its declaration
	 */
	rule <k> ( Initial: Q:Int => .K ) ... </k>
		<initial-state> InitialState:Int => Q </initial-state>
		<current-state> CurrentState:Int => Q </current-state>
		<states> S:Set </states>
			when Q in S

	/*
	 * Save configuration into the Map Transition. 
	 * Given a quintuple, (CurrentState, ReadChar, NextState, WritingChar , M), the 
	 * rule save in Transition the key (CurrentState, ReadChar) with value 
	 * (NextState, WritingChar , M) iff:
	 * - the pair (CurrentState, ReadChar) isn't already in keys of Transition
	 * - NextState and CurrentState are declared into States List.
	 * - ReadChar and WritingChar have length 1.
	 */
	rule <k> 
			( (CurrentState:Int , ReadChar:String , NextState:Int , WritingChar:String , M:Movement) => .K ) ... 
		 </k>
		 <transitions>
		 	Transitions:Map => (Transitions[(CurrentState, ReadChar) <- (NextState, WritingChar, M)])
		 </transitions>
		 <states> S:Set </states>
		 	when notBool((CurrentState, ReadChar) in keys(Transitions)) 
		 			andBool CurrentState in S 
		 			andBool NextState in S 
		 			andBool lengthString(ReadChar) ==Int 1
		 			andBool lengthString(WritingChar) ==Int 1

	/*
	 * Save list of given initial tape into tape's map (Tape).
	 * The rules save the Read char and check if the length 
	 * of char is equal to 1. 
	 */
	rule <k> ( Char:String, Chars:InitialTape => Chars ) ... </k>
		 <tape> Tape:Map => Tape[size(Tape) <- Char] </tape>
		 	when lengthString(Char) ==Int 1

	rule <k> ( Char:String, .InitialTape => .K ) ... </k>
		 <tape> Tape:Map => Tape[size(Tape) <- Char] </tape>
		 	when lengthString(Char) ==Int 1		 

	/*
	 * The rule allows to take a step of computation. 
	 * The CurrentState and value of ReadChar in CurrentPosition is 
	 * used to find, if exist, the correct transition to apply. 
	 */
	rule <k> .K </k>
		 <transitions> 
		 	... (CurrentState, ReadChar:String)|-> (NextState:Int, WritingChar:String, M:Movement) ... 
		 </transitions> 
		 <current-position> CurrentPos:Int => CurrentPos +Int (updatePos M) </current-position>
		 <tape> Tape:Map => Tape[CurrentPos <- WritingChar] </tape>
		 <current-state> CurrentState:Int => NextState </current-state> 
		 	when CurrentPos in keys(Tape) andBool ReadChar ==TapeChar Tape[CurrentPos]

	/* 
	 * Second rule that allows to take a step of computation. 
	 * This one is applied if CurrentPosition isn't already in keys of
	 * Tape and so ReadChar is automatically the symbol "$" (empty char/position).
	 */
	rule <k> .K </k>
		 <transitions> 
		 	... (CurrentState, ReadChar:String)|-> (NextState:Int, WritingChar:String, M:Movement) ... 
		 </transitions> 
		 <current-position> CurrentPos:Int => CurrentPos +Int (updatePos M) </current-position>
		 <tape> Tape:Map => Tape[CurrentPos <- WritingChar] </tape>
		 <current-state> CurrentState:Int => NextState </current-state> 
		 	when notBool(CurrentPos in keys(Tape)) andBool ReadChar ==TapeChar "$" 


	/*
	 * Modify current position given the movement
	 */
	 syntax Int ::= "updatePos" K  [function]
	 rule updatePos R => 1
	 rule updatePos - => 0
	 rule updatePos L => 0 -Int 1

	/*
	 * Equals with tape chars
	 */
	syntax Bool ::= K "==TapeChar" K [function]
	rule "*" ==TapeChar S:String => true
	rule S:String ==TapeChar "*" => true
	rule S1:String ==TapeChar S2:String => S1 ==String S2 when S1 =/=String "*" andBool S2 =/=String "*"

endmodule