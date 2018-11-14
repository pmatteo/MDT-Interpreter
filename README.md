# MDT Interpreter
Turing Machine interpreter build with K-Framework v4.

## Intallation
- First of all, download and install K-Framework from [here](https://github.com/kframework/k)
- Download the interpreter from GitHub using git (`git clone https://github.com/pmatteo/MDT-Interpreter.git`) and compile it with the following command:

``` 
kompile mdt.k
```

## How to use
To run an mdt from a file named _example.mdt_, execute the command:

```
krun example.mdt
```
Of course if the file isn't in your current directory, the command need also the path (absolute or relative).

## Example of MDT configuration
The interpreter need a specific syntax to parsing the file and execute the machine. The structure of .mdf files is:

- List of used states separeted by comma and the state's name must be a number. Example: `0, 1, 2, 3, 4, 5`
- The keyword _Final:_ followed by the final state number. Exmaple `Final: 5`
- The keyword _Initial:_ followed by the initial state number. Example: `Initial: 0`
- List of transitions of the machine in this form _(stateToMatch, charToMatch, newState, charToWrite, movementOnTape)_ where movement is _L_ for left, _R_ for right and _-_ to stay in current position on tape. Example: `(0, "h", 1, "h", R)`, `(0, "h", 1, "h", L)`
- Starting tape configuration which is a list of characters separated by comma. Example: `"h", "e", "l", "l", "o"`

The program check if every single state is already defined in the state's list and the repeted pair (stateToMatch, charToMatch) into a transition will be ingnored. If the machine isn't in a correct form the program stop its execution.
Note also that there are 2 special character:
- _*_ which means "any character"
- _$_ that, following the standard for a turing machine, means "empty char".


An example of a simple tm which accept only the string "hello"

```
0, 1, 2, 3, 4, 5
Final: 5
Initial: 0

(0, "h", 1, "h", R)
(1, "e", 2, "e", R)
(2, "l", 3, "l", R)
(3, "l", 4, "l", R)
(4, "o", 5, "o", -)

"h", "e", "l", "l", "o"
```

Other 3 example, more complex, are into the folder "test". The file _AnBn.mdt_ accept all the string in the form a^nb^b. _Add1.md_ is a simple turing machine that add one to an given integer number. The last one, _reverseBinary.mdt_, write into tape the reverse of a given string.
