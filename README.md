# azure-cost

This is a quick-and-dirty Powershell script to keep track of your accumulated Azure spend. If any one resource consumes more than a certain threshold of your total bill, that could indicate a runaway instance, like a VM or database that you forgot to turn off when you were done using it.

When one or more services exceed the defined threshold, the script will invoke a Slack webhook to notify you or your team in your Slack channel or choice. 

You can set the threshold percentage as a parameter, or use the default 50%.

You'll need to add the webhook URL to your custom Slack integration to make this script work.

The Powershell script is designed to run as an Azure Automation runbook on a schedule.
