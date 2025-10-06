CREATE TABLE countries (
    id INT PRIMARY KEY,
    country_name VARCHAR(100)
);

INSERT INTO countries (id, country_name) VALUES 
(0, 'Albania'),
(1, 'Austria'),
(2, 'Belgium'),
(3, 'Bosnia and Herzegovina'),
(4, 'Bulgaria'),
(5, 'Croatia'),
(6, 'Cyprus'),
(7, 'Czechia'),
(8, 'Denmark'),
(9, 'Estonia'),
(10, 'Finland'),
(11, 'France'),
(12, 'Germany'),
(13, 'Greece'),
(14, 'Hungary'),
(15, 'Iceland'),
(16, 'Ireland'),
(17, 'Italy'),
(18, 'Kosovo*'),
(19, 'Latvia'),
(20, 'Lithuania'),
(21, 'Luxembourg'),
(22, 'Malta'),
(23, 'Montenegro'),
(24, 'Netherlands'),
(25, 'North Macedonia'),
(26, 'Norway'),
(27, 'Poland'),
(28, 'Portugal'),
(29, 'Romania'),
(30, 'Serbia'),
(31, 'Slovakia'),
(32, 'Slovenia'),
(33, 'Spain'),
(34, 'Sweden'),
(35, 'Switzerland'),
(36, 'Türkiye'),
(37, 'Ukraine'),
(38, 'European Union - 27 countries (from 2020)'),
(39, 'Liechtenstein'),
(40, 'Moldova');

ALTER TABLE countries ADD COLUMN regione VARCHAR(50);

UPDATE countries SET regione = 'UE Scandinava' WHERE country_name IN ('Denmark', 'Sweden', 'Finland') AND id > 0;
UPDATE countries SET regione = 'UE Meridionale' WHERE country_name IN ('Italy', 'Spain', 'Portugal', 'Greece', 'Malta', 'Cyprus') AND id > 0;
UPDATE countries SET regione = 'UE Est Centrale' WHERE country_name IN ('Poland', 'Czechia', 'Slovakia', 'Hungary', 'Romania', 'Bulgaria', 'Slovenia', 'Croatia', 'Lithuania', 'Latvia', 'Estonia') AND id > 0;
UPDATE countries SET regione = 'UE Occidentale' WHERE country_name IN ('France', 'Germany', 'Netherlands', 'Belgium', 'Austria', 'Ireland', 'Luxembourg') AND id > 0;



SELECT * FROM gdp_totale_per_paese_market_price_milioni;

SELECT * FROM mutuo_affitto_utility_gdp m
JOIN countries c ON
m.id_paese = c.id;


CREATE OR REPLACE VIEW tendenze_di_crescita_economica AS
SELECT
    g.stato AS Stato,
    g.OBS_VALUE AS Gdp_totale,
    gd.OBS_VALUE AS Gdp_per_capita,
    g.TIME_PERIOD AS Anno
FROM
    gdp_totale_per_paese_market_price_milioni g
JOIN
    gdp_per_capita_in_euro gd
    -- La condizione di JOIN ora include sia il paese che l'anno
    ON g.id_paese = gd.id_paese AND g.TIME_PERIOD = gd.TIME_PERIOD;

CREATE OR REPLACE VIEW tendenze_di_crescita_economica_regioni_eu AS
SELECT
    c.regione AS Regione,
    g.TIME_PERIOD AS Anno,
    SUM(g.OBS_VALUE) AS Gdp_totale,
    AVG(gd.OBS_VALUE) AS Gdp_per_capita
FROM
    gdp_totale_per_paese_market_price_milioni g
JOIN
    gdp_per_capita_in_euro gd
    ON g.id_paese = gd.id_paese AND g.TIME_PERIOD = gd.TIME_PERIOD
JOIN
    countries c ON gd.id_paese = c.id
GROUP BY
    c.regione, g.TIME_PERIOD;


select * from V_Analisi_Economica_Europa_disoccupazione;
    
CREATE OR REPLACE VIEW V_Analisi_Economica_Europa_disoccupazione AS
SELECT
    dtp.stato AS Stato,
    dtp.TIME_PERIOD AS Anno,
    dtp.OBS_VALUE AS Disoccupazione_Totale_Percentuale,
    dmp.OBS_VALUE AS Disoccupazione_Maschile_Percentuale,
    dfp.OBS_VALUE AS Disoccupazione_Femminile_Percentuale
FROM
    Disoccupazione_totale_percentuale AS dtp
LEFT JOIN Disoccupazione_maschile_percentuale AS dmp
    ON dtp.stato = dmp.stato AND dtp.TIME_PERIOD = dmp.TIME_PERIOD
LEFT JOIN Disoccupazione_femminile_percentuale AS dfp
    ON dmp.stato = dfp.stato AND dmp.TIME_PERIOD = dfp.TIME_PERIOD;

-- View povertà
CREATE OR REPLACE VIEW vista_poverta_sotto60_facile_arrivare_fine_mese AS
SELECT
rpt.stato AS Stato,
rpt.TIME_PERIOD AS Anno,
rpt.OBS_VALUE AS rischio_povertà_totale_perc,
rpm.OBS_VALUE AS rischio_povertà_maschile_perc,
rpf.OBS_VALUE AS rischio_povertà_femminile_perc,
itffe.OBS_VALUE AS inabilità_fronteggiare_spese_perc,
itmee.OBS_VALUE AS perc_fine_mese_facile,
itmed.OBS_VALUE AS perc_fine_mese_difficile
FROM rischio_poverta_totale AS rpt 
LEFT JOIN rischio_poverta_maschile AS rpm
	ON rpt.stato = rpm.stato AND rpt.TIME_PERIOD = rpm.TIME_PERIOD
LEFT JOIN rischio_poverta_femminile AS rpf
	ON rpm.stato = rpf.stato AND rpm.TIME_PERIOD = rpf.TIME_PERIOD
LEFT JOIN Inability_to_face_unexpected_financial_expenses_percentuale_pop AS itffe
	ON rpf.stato = itffe.stato AND rpf.TIME_PERIOD = itffe.TIME_PERIOD
LEFT JOIN Inability_to_make_ends_meet_easy_conditions AS itmee
	ON itffe.stato = itmee.stato AND itffe.TIME_PERIOD = itmee.TIME_PERIOD
LEFT JOIN Inability_to_make_ends_meet_difficulty_conditions AS itmed
	ON itmee.stato = itmed.stato AND itmee.TIME_PERIOD = itmed.TIME_PERIOD;


CREATE OR REPLACE VIEW settori_economici AS
SELECT
gsa.stato AS Stato,
gsa.TIME_PERIOD AS Anno,
gsa.OBS_VALUE AS gdp_agricoltura,
gsades.OBS_VALUE AS gdp_amministrazione_difesa_educazione_salute,
gsais.OBS_VALUE AS gdp_arte_intrattenimento,
gsi.OBS_VALUE AS gdp_industria,
gspst.OBS_VALUE AS gdp_primario_secondario_terziario,
gsvtca.OBS_VALUE AS gdp_vendite_trasporti_case_alimenti,
mau.OBS_VALUE AS gdp_mutui_affitti_utility
FROM gdp_settore_agricolo AS gsa
LEFT JOIN gdp_x_settore_amministrazione_difesa_educazione_salute AS gsades
	ON gsa.stato = gsades.stato AND gsa.TIME_PERIOD = gsades.TIME_PERIOD
LEFT JOIN gdp_x_settore_arte_intrattenimento_servizi AS gsais
	ON gsades.stato = gsais.stato AND gsades.TIME_PERIOD = gsais.TIME_PERIOD
LEFT JOIN gdp_x_settore_industria AS gsi
	ON gsais.stato = gsi.stato AND gsais.TIME_PERIOD = gsi.TIME_PERIOD
LEFT JOIN gdp_x_settore_primario_secondario_terziario AS gspst
	ON gsi.stato = gspst.stato AND gsi.TIME_PERIOD = gspst.TIME_PERIOD
LEFT JOIN gdp_x_settore_vendite_trasporti_case_alimenti AS gsvtca
	ON gspst.stato = gsvtca.stato AND gspst.TIME_PERIOD = gsvtca.TIME_PERIOD
LEFT JOIN mutuo_affitto_utility_gdp AS mau
	ON gsvtca.stato = mau.stato AND gsvtca.TIME_PERIOD = mau.TIME_PERIOD;
    
    
    
SELECT * FROM vista_poverta_sotto60_facile_arrivare_fine_mese;
