-- SELECT * from PortfolioProject..Vaccinations
-- WHERE continent is not null
-- ORDER BY 3,4


-- Select Data that we are going to use



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Deaths
WHERE continent is not null
ORDER BY 1,2

------------------------------------------------------------------


-- Looking at Total Cases vs Total Deaths by Country
-- Shows the Death Rate if you contract the virus in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..Deaths
Where location like '%states%' and continent is not null
ORDER BY 1,2


------------------------------------------------------------------

-- Deaths by continent
SELECT continent, max(cast(total_deaths as int)) AS PeakDeaths
FROM PortfolioProject..Deaths
-- Where Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY PeakDeaths DESC


------------------------------------------------------------------

-- Looking at Total Cases vs. Population
-- Shows the percentage of population that contracted the virus

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CaseRate
FROM PortfolioProject..Deaths
Where location like '%states%' and continent is not null 
ORDER BY 1,2


------------------------------------------------------------------


-- Countries that have the highest infection rate compared to the population

SELECT Location, population, max(total_cases) AS PeakInfectionCount, max((total_cases/population))*100 AS CaseRate
FROM PortfolioProject..Deaths
WHERE continent is not null
GROUP BY population, location
ORDER BY PeakInfectionCount DESC

------------------------------------------------------------------

-- Showing Continent with the highest death rate
-- Converting/Casting total_deaths as interger

SELECT Location, max(cast(total_deaths as int)) AS PeakDeaths
FROM PortfolioProject..Deaths
-- Where Location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY PeakDeaths DESC


------------------------------------------------------------------

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-------------------------------------------------------------------

-- Join the Tables

SELECT * 
FROM PortfolioProject..Deaths dea
JOIN PortfolioProject..Vaccinations vac
on dea.location = vac.location
and dea.date = vac.date

-------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
ORDER BY 2,3

--------------------------------------------------------------------

-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--ORDER BY 2,3
)
SELECT * from PopvsVac

-------------------------------------------------------------------------------------

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
