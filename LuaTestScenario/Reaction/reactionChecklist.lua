--[[
Here are some things to check (or double check) in your reaction setup

1.  Have you linked the state?
state.reactionTable= state.reactionTable or {}
reactionBase.linkState(state.reactionTable)

2.  If using limited reactions per unit per turn, have you included
reactionBase.clearReactionsIfNecessary(tribe,true) in the after production code for each tribe?


