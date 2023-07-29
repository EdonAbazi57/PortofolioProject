
/*The SQL code analyzes COVID-19 data, sorting it by location and date, and calculating the percentage of total deaths relative to total cases for a specific location.*/
select * from coviddeaths order by 3,4;
select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths order by 1,2;

/*This SQL query calculates and compares the percentage of total deaths to total cases for COVID-19 in Macedonia, sorting the results by location and date.*/
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percent
from coviddeaths 
where location like '%macedonia%'
order by 1,2;

/*This SQL query calculates the percentage of the population that has been infected with COVID-19 in different locations, considering the total cases and population data, and then groups 
the results by population and location, sorting them by location and date.*/
select location,da te,total_cases, population,(total_cases/population)*100 as percet_of_population_infected 
from coviddeaths 
/*where location like '%macedonia%'*/
group by population,location
order by 1,2;

/*Identify the location with the highest infection rate by comparing total cases to population and calculate the percentage of the population affected */
select location,MAX(total_cases) as higest_infectioncout, population,(max(total_cases)/population)*100 as percet_of_population
from coviddeaths 
/*where location like '%macedonia%'*/
order by 1,2;

/* Highest infection rate compoared to population */
select location,population,max(total_cases)as higestinfectedCount,max((total_cases/population))*100 as percentofPopulationInfected from coviddeaths
group by population,location
order by percentofPopulationInfected desc;

/* Countries with the highest death count per population */
Select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
From coviddeaths
/*Where location like '%states%'*/
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


/*Display the continents with the highest death count, considering non-null values for the continent, and order the results by the total number of deaths in descending order*/
select continent ,max(cast(total_deaths as double)) as total_deaths_count
from coviddeaths
where continent is not null
group by continent 
order by total_deaths_count;

/* COVID-19 data, providing total cases, total deaths, and death percentage by date and continent, as well as the total death percentage worldwide*/
select sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/sum(new_cases)*100 as Percent
from coviddeaths 
where continent is not null
/*group by date*/
order by 1,2;
/*code calculates the total death percentage worldwide, grouped by date, and ordered by date and total cases*/
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/sum(new_cases)*100 as Percent
from coviddeaths 
where continent is not null
group by date
order by 1,2;

/* ode compares total population and vaccination data, including continent, 
location, date, population, and new vaccinations, while also calculating the cumulative vaccinations for each location over time*/
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
   /* ,(cumulative_vaccinations/population)*100*/
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location, dea.date;

/*CTE to merge COVID-19 deaths and vaccination data, calculating cumulative vaccinations for
 each location over time, and presents the continent, location, date, population, new vaccinations, cumulative vaccinations, 
 and percentage of the population vaccinated, ordered by location and date*/

WITH PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations) AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS cumulative_vaccinations
    FROM
        coviddeaths dea
    JOIN
        covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations,
    cumulative_vaccinations,
    (cumulative_vaccinations / population) * 100 AS percentage_vaccinated
FROM
    PopvsVac
ORDER BY
    location, date;
    
    
/*code creates a temporary table called "PercentPopulationVaccinated," 
merging data from "CovidDeaths" and "CovidVaccinations" tables,
 and calculates the rolling number of people vaccinated and the percentage of the population vaccinated for each location over time*/

SET SQL_MODE = 'NO_ZERO_DATE';

-- Your other SQL statements here...
drop table if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

-- The rest of your SQL statements...
INSERT INTO PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    NULLIF(dea.date, '0000-00-00'), -- Replace zero dates with NULL
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    CovidDeaths dea
JOIN
    CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date;


SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM PercentPopulationVaccinated;

