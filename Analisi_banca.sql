/*
Creo delle tabelle temporanee per calcolare i KPI richiesti da associare successivamente 
nella query principale. Le tabelle temporanee contengono gli ID dei clienti e i rispettivi KPI calcolati.
*/
    
 -- Tabella temporanea per calcolare il KPI relativo al numero di conti posseduti da ciascun cliente
   create temporary table tab_conti as (
		select cl.id_cliente, count(id_conto) conti
		from banca.cliente cl
		left join banca.conto co on co.id_cliente = cl.id_cliente
		group by 1) 
-- Tabella temporanea per calcolare il KPI relativo al numero di conti posseduti da ciascun cliente per tipologia conto
	create temporary table tab_tipi_conti as (
		select cl.id_cliente, 
		count(case when id_tipo_conto = '0' then id_conto else null end) conti_base,
        count(case when id_tipo_conto = '1' then id_conto else null end) conti_business,
        count(case when id_tipo_conto = '2' then id_conto else null end) conti_privati,
        count(case when id_tipo_conto = '3' then id_conto else null end) conti_famiglie
		from banca.cliente cl
		left join banca.conto co on co.id_cliente = cl.id_cliente
		group by 1)    
-- Tabella temporanea per calcolare il KPI relativo al numero di transazioni per tipologia
	create temporary table tab_trans as (
		select cl.id_cliente, 
		count(case when id_tipo_trans = '0' then cl.id_cliente else null end) stipendi,
        count(case when id_tipo_trans = '1' then cl.id_cliente else null end) pensioni,
        count(case when id_tipo_trans = '2' then cl.id_cliente else null end) dividendi,
        count(case when id_tipo_trans = '3' then cl.id_cliente else null end) amazon,
        count(case when id_tipo_trans = '4' then cl.id_cliente else null end) mutuo,
        count(case when id_tipo_trans = '5' then cl.id_cliente else null end) hotel,
        count(case when id_tipo_trans = '6' then cl.id_cliente else null end) aereo,
        count(case when id_tipo_trans = '7' then cl.id_cliente else null end) supermercato
		from banca.cliente cl
        left join banca.conto co on co.id_cliente = cl.id_cliente
		left join banca.transazioni tra on tra.id_conto = co.id_conto
		group by cl.id_cliente) 
-- Tabella temporanea per calcolare il KPI relativo all'importo transato in uscita per tipologia di conto
	create temporary table importo_conti_uscita as (
		select cl.id_cliente, 
		sum(case when id_tipo_conto = '0' and id_tipo_trans in(3,4,5,6,7) then importo else 0 end) uscita_conto_base,
        sum(case when id_tipo_conto = '1' and id_tipo_trans in(3,4,5,6,7) then importo else 0 end) uscita_conto_business,
        sum(case when id_tipo_conto = '2' and id_tipo_trans in(3,4,5,6,7) then importo else 0 end) uscita_conto_privati,
        sum(case when id_tipo_conto = '3' and id_tipo_trans in(3,4,5,6,7) then importo else 0 end) uscita_conto_famiglia
		from banca.cliente cl
        left join banca.conto co on co.id_cliente = cl.id_cliente
		left join banca.transazioni tra on tra.id_conto = co.id_conto
		group by cl.id_cliente) 
-- Tabella temporanea per calcolare il KPI relativo all'importo transato in entrata per tipologia di conto
	create temporary table importo_conti_entrata as (
		select cl.id_cliente, 
		sum(case when id_tipo_conto = '0' and id_tipo_trans in(0,1,2) then importo else 0 end) entrata_conto_base,
        sum(case when id_tipo_conto = '1' and id_tipo_trans in(0,1,2) then importo else 0 end) entrata_conto_business,
        sum(case when id_tipo_conto = '2' and id_tipo_trans in(0,1,2) then importo else 0 end) entrata_conto_privati,
        sum(case when id_tipo_conto = '3' and id_tipo_trans in(0,1,2) then importo else 0 end) entrata_conto_famiglia
		from banca.cliente cl
        left join banca.conto co on co.id_cliente = cl.id_cliente
		left join banca.transazioni tra on tra.id_conto = co.id_conto
		group by cl.id_cliente) 


 -- Query che genera il report
select 
cli.*,
year(current_timestamp()) - year(data_nascita) -
case 
	when month(current_timestamp()) < month(data_nascita) 
    or (month(current_timestamp()) = month(data_nascita) and day(current_timestamp()) < day(data_nascita))
    then 1 else 0
end as eta,
count(case when tra.id_tipo_trans in (3,4,5,6,7) then tra.id_tipo_trans else null end) as 'Transazioni in uscita',
sum(case when tra.id_tipo_trans in (0,1,2) then 1 else 0 end) as 'Transazioni in entrata',
sum(case when tra.id_tipo_trans in (3,4,5,6,7) then tra.importo else 0 end) as 'Importo in uscita',
sum(case when tra.id_tipo_trans in (0,1,2) then tra.importo else 0 end) as 'Importo in entrata',
tab_conti.conti as 'Conti posseduti',
tab_tipi_conti.conti_base as 'Conti base passeduti',
tab_tipi_conti.conti_business as 'Conti business passeduti',
tab_tipi_conti.conti_privati as 'Conti privati passeduti',
tab_tipi_conti.conti_famiglie as 'Conti famiglie passeduti',
tab_trans.stipendi as 'Transazioni tipo stipendio',
tab_trans.pensioni as 'Transazioni tipo pensione',
tab_trans.dividendi as 'Transazioni tipo dividendi',
tab_trans.amazon as 'Transazioni tipo acquisti amazon',
tab_trans.mutuo as 'Transazioni tipo rata mutuo',
tab_trans.hotel as 'Transazioni tipo hotel',
tab_trans.aereo as 'Transazioni tipo biglietto aereo',
tab_trans.supermercato as 'Transazioni tipo supermercato',
importo_conti_uscita.uscita_conto_base as 'Importo in uscita conti base',
importo_conti_uscita.uscita_conto_business as 'Importo in uscita conti business',
importo_conti_uscita.uscita_conto_privati as 'Importo in uscita conti privati',
importo_conti_uscita.uscita_conto_famiglia as 'Importo in uscita conti famiglia',
importo_conti_entrata.entrata_conto_base as 'Importo in entrata conti base',
importo_conti_entrata.entrata_conto_business as 'Importo in entrata conti business',
importo_conti_entrata.entrata_conto_privati as 'Importo in entrata conti privati',
importo_conti_entrata.entrata_conto_famiglia as 'Importo in entrata conti famiglia'
from banca.cliente cli
	left join banca.conto con on con.id_cliente = cli.id_cliente
	left join banca.transazioni tra on tra.id_conto = con.id_conto
	left join banca.tipo_transazione titra on titra.id_tipo_transazione = tra.id_tipo_trans
	inner join tab_conti  on tab_conti.id_cliente = cli.id_cliente
    inner join tab_tipi_conti on tab_tipi_conti.id_cliente = cli.id_cliente
    inner join tab_trans  on tab_trans.id_cliente = cli.id_cliente
    inner join importo_conti_uscita on importo_conti_uscita.id_cliente = cli.id_cliente
    inner join importo_conti_entrata on importo_conti_entrata.id_cliente = cli.id_cliente
group by 1,2,3,4,tab_conti.conti, conti_base, conti_business, conti_privati, conti_famiglie, stipendi, pensioni, dividendi, amazon, mutuo, hotel, aereo, supermercato, uscita_conto_base, uscita_conto_business, uscita_conto_privati, uscita_conto_famiglia, entrata_conto_base, entrata_conto_business, entrata_conto_privati, entrata_conto_famiglia
order by cli.id_cliente
