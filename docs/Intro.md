# Introduction to DottDB

## What is DottDB
- Our goal is to build an in-memory graph database. Let's break that down

### In-Memory
- The database is stored in memory during execution. You load the entire database into memory for blazingly fast access speeds. 

### Graph Database
- A graph in this context is a collection of nodes and edges. The important focus of the data is the relationship between the nodes in the dataset. 


## Ok cool, but why?
-  Relationships in graph data tend to follow patterns. Think path finding. If you were to implement a path finding algorithm, you would be looking for a pattern in the data that satisfies a path. 
- One of the strengths of elixir/erlang is pattern matching. 

Are your wheels turning already? 

If not, here's the gist of it all. We will attempt to leverage Elixir's implicit pattern matching to enhance pattern discovery in the database. 

While we're at it, what else can we leverage from elixir?

Well, let's look at Elixir's description on their documentation.

> Elixir runs on the Erlang VM, known for creating **low-latency**, **distributed**, and **fault-tolerant** systems.

### Distributed. 
Graph data can be large. What if, instead of loading the entire dataset on one machine, we split the data and load it into multiple machines? An elixir node on my laptop in Kenya, and an Elixir node on a server in Belgium should look the same under the hood. If the message passing is done correctly, we could in fact distribute the pattern discovery algorithms. 

### Fault Tolerant. 
In memory data is not persisted. If we distribute our data and a node goes down, we will need to be able to quickly recover from these failures. We should focus on a way of making sure we can do this while abstracting such failures. 

### Low Latency
If you're performing a large search in a graph, that is also distributed, we should be able to reduce any latency as much as possible. Our goal is that the latency to only exist where it is unavoidable.


## Ensuring ACID-ity
Any Database system worth it's salt will need to maintain the ACID principles. ACID here stands for *Atomicity, Consistency, Isolation and Durability* There are variations, for instance, ArangoDB supports ACI but Durability is not strictly enforced.

### A - Atomicity
Any transaction occuring on the database should be atomic. That is to say, each transaction should occur as a single unit, which either succeeds completely or fails completely. 

### C- Consistency
Each transaction executed by the database should move the database from one consistent state to another consistent state. The database must remain valid according to the defined rules. 

### I - Isolation
Concurrently executed transactions leave the database in a state that they would, if the same transactions were executed sequentially. 

### D - Durability
This guarantees that once a transaction has been committed, it will remain committed, even if there is a system failure. 
