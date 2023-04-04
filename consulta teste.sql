SELECT UNIQUE region, PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region) AS 'PrimeiroQuadrante',
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region) AS 'Mediana',
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region) AS 'TerceiroQuadrante',
(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region)) - 
(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region)) AS 'Intervalo Interquartil',
(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region)) + 
1.5 * (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region)) - 
(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ordercreationtimeminutes) OVER (PARTITION BY region)) AS 'Limite dos Outliers'
FROM entregas;

SELECT (SELECT COUNT(*) FROM entregas WHERE region = 'sudeste'  AND state = 'RJ' and shipment_cost > 
(SELECT unique PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY shipment_cost) OVER (PARTITION BY region) FROM entregas WHERE region = 'sudeste'))
/ (Select COUNT(*) FROM entregas WHERE region = 'sudeste' and shipment_cost > 
(SELECT unique PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY shipment_cost) OVER (PARTITION BY region) FROM entregas WHERE region = 'sudeste')) * 100
AS 'Porcentagem outliers no RJ / outliers Sudeste';

SELECT * FROM entregas WHERE in_transit_to_local_distribution_at IS NOT NULL AND local_distribution_at IS not null;

 -- Preenchimento de prazos totais 1
UPDATE entregas SET tempoTotalEntrega = (COALESCE(leavingCentralDistributionMinutes, 0) + COALESCE(arrivalLocalDistributionMinutes, 0) + COALESCE(departureLocalDistributionMinutes, 0) + COALESCE(deliveryTimeMinutes, 0)) / 60;

UPDATE entregas SET arrivalLocalDistributionMinutes = (TIMESTAMPDIFF(MINUTE, in_transit_to_local_distribution_at , delivered_at)) WHERE arrivalLocalDistributionMinutes IS NULL AND local_distribution_at IS NULL AND delivered_at IS not NULL;

SELECT * FROM entregas WHERE delivered_at IS NULL AND STATUS = 'delivered';
;
;
;
;
;
;