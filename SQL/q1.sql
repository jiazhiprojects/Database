 SET search-path TO parlgov;

CREATE TABLE q1(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

--All pairs that have formed an alliance in a certain election in a certain country.
CREATE VIEW All_pairs AS
  SELECT E1.party_id , E2.party_id, election.country_id as county_id
  FROM election_result E1, election_result E2, election
  WHERE E1.election_id = election.id AND
      E1.election_id = E2.election_id AND
      E1.party_id < E2.party_id AND
      (E1.alliance_id = E2.alliance_id OR 
      E1.alliance_id = E2.id OR 
      E2.alliance_id = E1.id)
  GROUP BY E1.party_id, E2.party_id, election_id, country_id;

--For each country, count the total number of elections happened.
CREATE VIEW Country_total AS
  SELECT COUNT(country_id) AS num_elections
  FROM election
  GROUP BY country_id;

CREATE VIEW Answer AS
  SELECT All_pairs.country_id, E1.party_id, E2.party_id, 
  FROM All_pairs, Country_total
  WHERE All_pairs.country_id = Country_total.country_id
  GROUP BY E1.party_id , E2.party_id, county_id, Country_total.num_elections
  HAVING COUNT(*) >= (Country_total.num_elections * 0.3);

insert into q1
SELECT All_pairs.country_id AS countryId, E1.party_id AS alliedPartyId1, E2.party_id AS alliedPartyId2
FROM Answer;
  

