---
title: "Multi-Region"
linkTitle: "Multi-Region"
weight: 5
description: How to use Opta to deploy multi-region environments
---

## Warning: Here be Dragons!
Out of the love and responsibility we feel towards our users we must seriously ask you and your team: are you **SURE**
you need this?

Multi-region, even in a perfect devops world (which opta, nor any tool, is) is a really hard 
application side problem (i.e. your server code). The users will need to make their code knowingly switch from read to 
write replicas of the datastore, be tolerant to read lag, ideally even know what region it’s in and keep a sort of 
network map to know what app is in which region to optimize its http requests, and even more... There’s a ton of ways to 
mess this up, and it should only be really attempted to reach disparate user locales or maybe for some reliability scenarios 
(but that’s debatable and a conversation for another time). The big fish can do this because, well, they can throw an 
insane amount of money and talent to these problems-- but us mortals need to be clever and choose our battles. If you're
mostly interested in site reliability, Opta should already have you covered via our 
[high availability with azs](/features/networking/high_availability)

Opta hears its needs from its customers and is striving to make even these requirements not only feasible, but also
as easy to implement as possible. That's not to say it will be easy-- again, multi-region architectures are
always on the next level of complexity **AND COST**, both in the cloud resources and application code. But even in this 
new level, the Opta team will offer its simplicity and ease of us.


