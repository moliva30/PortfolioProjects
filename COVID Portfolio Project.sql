SELECT *
FROM `portfolio-project1-392619.covid_data.deaths`
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-project1-392619.covid_data.deaths` 
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in any given country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `portfolio-project1-392619.covid_data.deaths`
WHERE location like "%states%"
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows percentage of population diagnosed with COVID
SELECT location, date, total_cases, new_cases, Population, (total_cases/population)*100 as CovidPercentage
FROM `portfolio-project1-392619.covid_data.deaths`
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
FROM `portfolio-project1-392619.covid_data.deaths`
GROUP BY Location, Population
ORDER BY CovidPercentage desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM `portfolio-project1-392619.covid_data.deaths`
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Breaking things down by continent
-- Showing continents with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM `portfolio-project1-392619.covid_data.deaths`
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global data
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM `portfolio-project1-392619.covid_data.deaths`
WHERE continent is not null
ORDER BY 1,2

-- Analyzing Total Population vs Vaccinations

SELECT dea.continent, dea.locaiton, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated, (RollingCountVaccinated/population)*100
FROM `portfolio-project1-392619.covid_data.deaths` dea
Join `portfolio-project1-392619.covid_data.vaccinations` vac
	On dea.locaiton = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

-- USING CTE
With PopsvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinated)
	as
(
SELECT dea.continent, dea.locaiton, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCountVaccinated, (RollingCountVaccinated/population)*100
FROM `portfolio-project1-392619.covid_data.deaths` dea
Join `portfolio-project1-392619.covid_data.vaccinations` vac
	On dea.locaiton = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3
)
SELECT *, (RollingCountVaccinated/Population)*100
FROM PopvsVac