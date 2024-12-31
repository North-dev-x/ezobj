### What the code does:

In a for loop, instantiate 10,000 instances of a class.
This class has the fields `value: number` and `id: string`, and the method `method`
Each instance gets their `value` assigned to a random number between -20000 and 20000.
Each instance gets their `id` assigned to a random UUID.
The method `method` returns a string of the `value` concatenated with the `id`.

On each iteration, push the result of a call of `method` to an array.

### Languages I benchmarked with this: 

Rust(built in release mode): 1-2ms

Luau(with ezobj): 14-21ms

Rust(opt-level 0): 20-22ms

Javascript(running on nodejs): 500-550ms

### Extras
I do not believe this to be a conclusive test, as my methods may be lacking and my javascript may be terrible.
