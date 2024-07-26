-- ALTER TABLE coviddeaths
-- ALTER COLUMN total_cases TYPE NUMERIC;


select * from coviddeaths
order by 3,4
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- Around the world
with Global (TotalCases, TotalDeaths) 
as
(
select SUM(cast(new_cases as int)) as TotalCases, 
SUM(cast(new_deaths as numeric)) as TotalDeaths
from coviddeaths
where continent is not null
)
select *, TotalDeaths/TotalCases as DeathsPerCases
from Global


--looking at total cases vs total deaths, mortality rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPerCases 
from coviddeaths
where location = 'United Kingdom'
order by 1,2;

-- Total cases per population
select location, date, total_cases, population, cast((total_cases/population)*100
as FLOAT(5)) as CasesPerPopulation  
from coviddeaths
where location = 'North Korea'
order by 1,2;

--The biggest number of people per million infected 
select location, population, MAX(total_cases) as MaxTotalCases, MAX((total_cases/population))*1000000 as CasesPerMillion
from coviddeaths
group by location, population
order by 4 DESC

select location, population, MAX(cast(total_deaths as INT)) as MaxTotalDeaths
from coviddeaths
group by location, population
order by 3 DESC;

-- The biggest number of deaths according to continents
select location, MAX(cast(total_deaths as INT)) as MaxTotalDeaths
from coviddeaths
where continent is null
group by location 
order by 2 desc

-- Percentage of people vaccinated out of total population
with PV_TP (location, date, population, new_vaccination, TotalVaccinatedPerDate)
as
(
select dea.location, dea.date, dea.population, vac.new_vaccinations, 
(SUM(vac.new_vaccinations) OVER (Partition by dea.location order BY dea.location, dea.date))
as TotalVaccinatedPerDate
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
)
SELECT *, (TotalVaccinatedPerDate/Population)*100 as PeopleVaccinatedVsPopulation
FROM PV_TP

-- Creating View to store data for later visualisation
CREATE VIEW PeopleVaccinated as
select dea.location, dea.date, dea.population, vac.new_vaccinations, 
(SUM(vac.new_vaccinations) OVER (Partition by dea.location order BY dea.location, dea.date))
as TotalVaccinatedPerDate
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3