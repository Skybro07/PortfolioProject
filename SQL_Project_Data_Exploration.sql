select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject ..CovidDeaths
WHERE continent is not null

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying chane if you get contaminated with covid in your country

select location, date, (total_cases) ,(total_deaths), (CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 
        END) AS percentageofDeaths
from  portfolioproject.. CovidDeaths
where location like '%states%'

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, (total_cases) ,population, (CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)*100 
        END) AS infectedPercentage

from  CovidDeaths
where location like '%states%'

--Looking at countries with Highest Infection rate compared to population
SELECT location, population,  MAX(total_cases) as HighestInfectionCount , 
MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100 AS percentagePopulationInfected
from CovidDeaths
WHERE continent is not null
GROUP by location, population
ORDER BY  percentagePopulationInfected desc

-- showing the countries whith highest deathcounts per population

SELECT location, population,  MAX(total_deaths) as HighestDeathsCount,  
MAX(CAST(total_deaths AS FLOAT) / population )*100 AS DeathsPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP by location, population
ORDER BY  HighestDeathsCount  desc
--ORDER BY  DeathsPercentage desc

-- Grouping the result on the basis of continent
SELECT location,  MAX(total_deaths) as HighestDeathsCount 
FROM CovidDeaths
WHERE continent is  null
GROUP By location
ORDER BY  HighestDeathsCount  desc

-- Global Numbers 
SELECT  SUM(new_cases) AS DailyNewCases, SUM(new_deaths) AS DailyNewDeaths, 
(SUM(CAST (new_deaths AS FLOAT)) / SUM(CAST (new_cases AS FLOAT) ))*100 as DeathPecrentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2





-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.date)
AS  RollingPeopleVaccinated
FROM  CovidDeaths AS dea
Join CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
   

--USE CTE

WITH PopvsVAC (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.date)
AS  RollingPeopleVaccinated
FROM  CovidDeaths AS dea
Join CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (CAST(RollingPeopleVaccinated AS float) / population  )*100  AS VaccinationPercentage
FROM PopvsVAC



-- TEMP TABLE 
DROP TABLE IF exists  #PercentTotalVaccinated
CREATE TABLE  #PercentTotalVaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentTotalVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.date)
AS  RollingPeopleVaccinated
FROM   portfolioproject.. CovidDeaths AS dea
Join portfolioproject.. CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (CAST(RollingPeopleVaccinated AS float) / population  )*100 
FROM #PercentTotalVaccinated
ORDER BY 4 desc



-- Creating View  to store data for later visualizations

CREATE VIEW PercentTotalVaccinated  as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY  dea.location ORDER BY dea.date)
AS  RollingPeopleVaccinated
FROM   portfolioproject.. CovidDeaths AS dea
Join portfolioproject.. CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM  PercentTotalVaccinated




