
SELECT COUNT(*) FROM PortfolioProject..CovidDeaths;
SELECT *FROM PortfolioProject..CovidDeaths
ORDER BY date; 
SELECT COUNT(*) FROM PortfolioProject..CovidVaccinations;
-- Remove the continents from the table
-- Where continent is not Null

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select Data that we are going to be using

SELECT  Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths 


SELECT Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like 'Germany'
ORDER BY 1,2;


-- Total Cases vs Population

SELECT Location,date, Population, total_cases, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
where location like 'Germany'
ORDER BY 1,2;

-- Countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) as  HighestInfectionCount,
((MAX(total_cases)/population))*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location,Population
ORDER BY CovidPercentage DESC;

-- Countries with Highest Death Count per Population
-- Here, one needs to change the datatype of total_deaths, cast(... as int)
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Death Count per Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Upper one has a problem to show the correct number of deaths
-- Use continent is null 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--  Total Population vs Vaccinations
-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccination )
AS(
SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as CumulativeVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT * , (CumulativeVaccination/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccination numeric

)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as CumulativeVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent is not null


SELECT *, (CumulativeVaccination/Population)*100 
FROM #PercentPopulationVaccinated

-- Create View to stora data for visualization 

CREATE VIEW PercentPopulationVaccinated as
(
SELECT dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
Order by dea.location, dea.date) as CumulativeVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null)



