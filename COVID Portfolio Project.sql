SELECT *
	FROM PortfolioProject..CovidDeaths
	WHERE continent is not null
	ORDER BY 3,4


--SELECT *
--	FROM PortfolioProject..CovidVaccinations
--	ORDER BY 3,4

--SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject..CovidDeaths
	ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths
	WHERE location like '%Germany%'
	ORDER BY 1,2

--Looking at the total cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, total_cases, Population,(total_cases/Population)*100 as PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%Germany%'
	ORDER BY 1,2


--looking at countries with Highst Infection Rate compared to Population
SELECT Location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/Population)*100 as PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%Germany%'
	GROUP BY Location, Population
	ORDER BY PercentPopulationInfected DESC


--Showing continent with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths
	--WHERE location like '%Germany%'
	WHERE continent is not null
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

--Global numbers
SELECT SUM(new_cases) as total_ceses, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Germany%'
where continent is not null
--GROUP BY date
order by 1,2


--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 can't use the new build column directly. There's two ways to solve the problem: CTE or TEMP TABLE
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RolliingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --at theses two places the colomns' number must be the same
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 can't use the new build column directly
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationCaccinated
CREATE TABLE #PercentPopulationCaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationCaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 can't use the new build column directly
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationCaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --at theses two places the colomns' number must be the same
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100 can't use the new build column directly
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationCaccinated