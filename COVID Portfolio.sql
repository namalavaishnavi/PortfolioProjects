-- selecting required data from covid deaths

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio..CovidDeaths
order by 1,2 

-- total cases vs total deaths
SELECT location, date, total_cases, total_deaths, 
		(total_deaths / total_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths 

--population vs total cases
SELECT location, date, total_cases, population,
		(total_cases/population)*100  as PercentPopulationInfected
FROM Portfolio..CovidDeaths 

-- Countries with highest infection rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population)*100) as PercentPopulationInfected
FROM Portfolio..CovidDeaths
Group by location, population
order by PercentPopulationInfected

--Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
	(SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM Portfolio..CovidDeaths 
WHERE continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations

SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (Partition by cd.location 
									order by cd.location, cd.date) 
									as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths cd
JOIN Portfolio..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null


-- USE CTE

With PopvsVac as (
SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location, cd.date) 
									as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths cd
JOIN Portfolio..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO PercentPopulationVaccinated 
SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location, cd.date) 
									as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths cd
JOIN Portfolio..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date


--Creating view to store data fro later visualizations
CREATE VIEW PercentPopulationVaccination as 
SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (Partition by cd.location order by cd.location, cd.date) 
									as RollingPeopleVaccinated
FROM Portfolio..CovidDeaths cd
JOIN Portfolio..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null