# azure-cost

This is a quick-and-dirty Powershell script to keep track of your accumulated Azure spend. If any one resource consumes more than a certain threshold of your total bill, that could indicate a runaway instance, like a VM or database that you forgot to turn off when you were done using it.

You can set the threshold percentage as a parameter, or use the default 50%.
