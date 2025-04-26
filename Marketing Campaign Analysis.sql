SELECT ad_date, campaign_id, adset_id, spend, impressions, reach, clicks, leads, value, url_parameters, total
FROM public.facebook_ads_basic_daily fabd;

select *
from facebook_adset fa 

select *
from facebook_campaign fc 

select *
from google_ads_basic_daily gabd 




--1
select 
	fabd.ad_date,
	fc.campaign_name, 
	fa.adset_name,
	fabd.spend,
	fabd.impressions,
	fabd.reach,
	fabd.clicks,
	fabd.leads,
	fabd.value 
from facebook_ads_basic_daily fabd 
left join facebook_adset fa on fabd.adset_id=fa.adset_id 
left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id 
;




--2 new
with new_table as 
	(select 
		fabd.ad_date,
		'google' as media_sourse,
		fc.campaign_name, 
		fa.adset_name,
		fabd.spend,
		fabd.impressions,
		fabd.reach,
		fabd.clicks,
		fabd.leads,
		fabd.value 
	from facebook_ads_basic_daily fabd 
	left join facebook_adset fa on fabd.adset_id=fa.adset_id 
	left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id)
select *
from new_table
union all 
select 
	ad_date,
	'facebook' as media_sourse,
	campaign_name,
	adset_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from google_ads_basic_daily gabd 


--3 new
with new_table as 
	(select 
		fabd.ad_date,
		'google' as media_sourse,
		fc.campaign_name, 
		fa.adset_name,
		fabd.spend,
		fabd.impressions,
		fabd.reach,
		fabd.clicks,
		fabd.leads,
		fabd.value 
	from facebook_ads_basic_daily fabd 
	left join facebook_adset fa on fabd.adset_id=fa.adset_id 
	left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id),
table_PA as 
	(select *
	from new_table
	union all 
	select 
		ad_date,
		'facebook' as media_sourse,
		campaign_name,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
	from google_ads_basic_daily gabd)
select 	
	ad_date,
	media_sourse,
	campaign_name,
	adset_name,
	sum (spend) as total_spend,
	sum (clicks) as total_clicks,
	sum (impressions) as total_impr,
	sum (value) as total_value
from table_PA
group by 1, 2, 3, 4
order by ad_date






--додаткове завдання

with table_PA as	
	(select 
		fabd.ad_date,
		'google' as media_sourse,
		fc.campaign_name, 
		fa.adset_name,
		fabd.spend,
		fabd.impressions,
		fabd.reach,
		fabd.clicks,
		fabd.leads,
		fabd.value 
	from facebook_ads_basic_daily fabd 
	left join facebook_adset fa on fabd.adset_id=fa.adset_id 
	left join facebook_campaign fc on fabd.campaign_id=fc.campaign_id
	union all 
	select 
		ad_date,
		'facebook' as media_sourse,
		campaign_name,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
	from google_ads_basic_daily gabd),
best_campaign as 
(select 	
	campaign_name,
	sum (spend) as total_spend,
	sum (clicks) as total_clicks,
	sum (impressions) as total_impr,
	sum (value) as total_value,
	round ((sum (value) - sum (spend)) :: numeric / sum (spend), 4) as ROMI
from table_PA
where clicks > 0
group by 1
having sum (spend) > 500000
order by ROMI desc
limit 1)
select 
	campaign_name,
	adset_name,
	round ((sum (value) - sum (spend)) :: numeric / sum (spend), 4) as ROMI
from table_PA 
where campaign_name in (select campaign_name from best_campaign) and clicks > 0
group by 1,2
order by ROMI
;


