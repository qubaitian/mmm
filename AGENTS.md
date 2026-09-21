when you chat, reply, docs, code comments, git commits:
    - Use simple and easy English.  
    - Active voice. Present tense.  
    - One word one meaning: same term for same thing.  
    - One idea per sentence.  
    - One sentence per line with two spaces.  

Use **Test-Driven Development**.  
    - Design **deep modules** that hide substantial behaviour behind a small, simple interface.  
    - Test module behaviour through those interfaces.  
    - Write the failing test first.  

Use **Conventional Commits** for commit messages.  
Use **Conventional Branch Name**.  

Interview the user until you share one understanding.  
Map the work as a **design tree**.  
Each decision branches into the decisions that depend on it.  

Work the tree in **rounds**.  
The **frontier** is every decision with settled prerequisites.  
Ask those questions now.  
Do not guess answers that the user did not give.  
Ask the full frontier in one round.  
Number each question.  
Give your recommended answer.  
Wait for the user's answers before the next round.  

Use this format for a round:

```
❓ **Q1** - **<question title>**: <question body. Add choices if needed.>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body. Add choices if needed.>

➡️ <your recommended answer>
```

User answers change the tree.  
Settled decisions move the frontier out.  
Those decisions open the questions that waited on them.  
Compute the frontier again.  
Ask the next round.  
If a question needs an answer that is still open in this round, put that question in a later round.  

Find **facts** yourself.  
Do not ask the user for data that you can look up.  
A running search is an unsettled prerequisite.  
Ask the rest of the frontier now.  
The user owns the **decisions**.  
Put each decision to the user and wait.  

The session is complete when the frontier is empty.  
Every branch of the design tree is visited.  
Nothing is assumed.  
Do not act until the user confirms a shared understanding.  

After the user confirms, write the shared understanding as **ADR** to `README.md`.
When to offer an ADR:
    All three of these must be true:
    - Hard to reverse: the cost of changing your mind later is meaningful
    - Surprising without context: a future reader will look at the code and wonder "why on earth did they do it this way?"
    - The result of a real trade-off: there were genuine alternatives and you picked one for specific reasons
    If a decision is easy to reverse, skip it: you'll just reverse it. 
    If it's not surprising, nobody will wonder why. 
    If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

If a new answer conflicts with a settled decision, raise the conflict at once.  
