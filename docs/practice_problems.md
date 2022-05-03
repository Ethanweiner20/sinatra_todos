# Practice Problems

1. We can use `map` on `result` because the `PG::Result` class includes the `Enumerable` module, which provides a `#map` instance method. `PG::Result#each` is defined such that it yields a tuple for each row to the block. Since `Enumerable` uses the `#each` method of the class into which it is included, invoking `#map` on a `PG::Result` instance gives us access to each of these tuples for transformation.
