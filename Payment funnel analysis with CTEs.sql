-- Task:
-- Count the number of subscriptions in each paymentfunnelstage as outlined in the code that I've given you by incorporating the maxstatus_reached and currentstatus per subscription.
-- Use  the paymentstatuslog and subscriptions tables

Solution:
with max_status_reached as (
select subscriptionid, max(Statusid)as maxstatus
from PaymentStatusLog
group by subscriptionid
)
,
paymentfunnelstages as(
	select subs.subscriptionid, 
	case when maxstatus = 1 then 'PaymentWidgetOpened'
		when maxstatus = 2 then 'PaymentEntered'
		when maxstatus = 3 and currentstatus = 0 then 'User Error with Payment Submission'
		when maxstatus = 3 and currentstatus != 0 then 'Payment Submitted'
		when maxstatus = 4 and currentstatus = 0 then 'Payment Processing Error with Vendor'
		when maxstatus = 4 and currentstatus != 0 then 'Payment Success'
		when maxstatus = 5 then 'Complete'
		when maxstatus is null then 'User did not start payment process'
		end as paymentfunnelstage
from subscriptions subs
left join max_status_reached m
on m.subscriptionid = subs.subscriptionid
)

select paymentfunnelstage, count(SUBSCRIPTIONID)as subscriptions
from paymentfunnelstages
group by paymentfunnelstage