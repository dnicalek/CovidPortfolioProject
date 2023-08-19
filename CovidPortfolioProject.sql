Select *
From PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations 
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, new_cases, total_deaths,
    CASE
        WHEN (TRY_CONVERT(float, total_cases) = 0 OR TRY_CONVERT(float, total_deaths) IS NULL OR TRY_CONVERT(float, total_deaths) = 0)
            THEN NULL
      ELSE (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)) * 100
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, total_deaths,
    CASE
        WHEN (TRY_CONVERT(float, total_cases) = 0 OR TRY_CONVERT(float, total_cases) IS NULL OR TRY_CONVERT(float, Population) = 0)
            THEN NULL
      ELSE (TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, Population)) * 100
    END AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
    CASE
        WHEN (TRY_CONVERT(float, MAX(total_cases)) = 0 OR TRY_CONVERT(float, MAX(total_cases)) IS NULL OR TRY_CONVERT(float, Population) = 0)
            THEN NULL
      ELSE MAX((TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, Population))) * 100
    END AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Looking at Countries with Highest Infection Rate compared to Population and displaying countries only with PercentPopulationInfected > 10%

WITH CalculatedData AS (
    SELECT 
        Location,
        Population,
        MAX(total_cases) as HighestInfectionCount,
        CASE
            WHEN (TRY_CONVERT(float, MAX(total_cases)) = 0 OR TRY_CONVERT(float, MAX(total_cases)) IS NULL OR TRY_CONVERT(float, Population) = 0)
                THEN NULL
            ELSE MAX((TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, Population))) * 100
        END AS PercentPopulationInfected
    FROM PortfolioProject..CovidDeaths
	Where continent is not null
    GROUP BY Location, Population
)
SELECT Location, Population, HighestInfectionCount, PercentPopulationInfected
FROM CalculatedData
WHERE PercentPopulationInfected > 10
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
    AND Location NOT LIKE '%income%'
    AND Location NOT IN ('World', 'European Union')
    AND Location NOT IN (SELECT DISTINCT continent FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL)
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Showing 10 Countries with Highest Death Count per Population
SELECT TOP 10
    Location,
    MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
    AND Location NOT LIKE '%income%'
    AND Location NOT IN ('World', 'European Union')
    AND Location NOT IN (SELECT DISTINCT continent FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL)
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Showing continents with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
    AND continent <> '' 
GROUP BY continent
ORDER BY TotalDeathCount DESC;


SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths cd1
WHERE continent IS NOT NULL
    AND continent <> ''
    AND continent IN (
        SELECT DISTINCT location
        FROM PortfolioProject..CovidDeaths cd2
        WHERE cd1.continent = cd2.location
    )
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Showing DeathPercentage by date

SELECT date,
       SUM(CAST(new_cases AS FLOAT)) AS TotalNewCases,
       SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
       CASE
           WHEN SUM(CAST(new_cases AS FLOAT)) = 0 THEN NULL
           ELSE SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;


-- Showing total death percentage on the world

SELECT
       SUM(CAST(new_cases AS FLOAT)) AS TotalNewCases,
       SUM(CAST(new_deaths AS FLOAT)) AS TotalNewDeaths,
       CASE
           WHEN SUM(CAST(new_cases AS FLOAT)) = 0 THEN NULL
           ELSE SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) * 100
       END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- GLOBAL NUMBERS

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date

SELECT DISTINCT *
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND dea.location NOT LIKE '%income%'
    AND dea.location NOT IN ('World', 'European Union')
    AND dea.location NOT IN (SELECT DISTINCT continent FROM PortfolioProject..CovidDeaths WHERE continent IS NOT NULL)
Order by dea.location, dea.date;


-- Looking at Total Population vs Vaccinations

Select DISTINCT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	AND dea.continent <> ''
	--and dea.location = 'Albania'
ORDER BY 1,2,3

SELECT DISTINCT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.continent <> ''
	AND dea.location = 'Albania'
ORDER BY
    2, 3;


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DISTINCT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.continent <> ''
	AND dea.location = 'Albania'
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac
Order by date


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinatedTable
Create Table #PercentPopulationVaccinatedTable
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinatedTable
SELECT DISTINCT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.continent <> ''
	AND dea.location = 'Albania'
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population) * 100 
From #PercentPopulationVaccinatedTable
Order by location, date


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinatedView as
SELECT DISTINCT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    AND dea.continent <> ''
	AND dea.location = 'Albania'
--ORDER BY 2, 3

Select *
From PercentPopulationVaccinatedView
Order by date