SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--- Select data that what we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%malaysia%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Show percentage of population get Covic

SELECT location, date,Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
ORDER BY 1,2

-- Looking at Country Highest Infection Rate compared to population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
GROUP by Location, Population
ORDER BY PercentPopulationInfected desc

--- Showing Countries Highest death count per Population

SELECT location, MAX(Total_deaths) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
GROUP by Location, Population
ORDER BY TotalDeathsCount desc

----have null in data, 

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
WHERE Continent is not null
GROUP by Location
ORDER BY TotalDeathsCount desc

--- Let Break things by continent

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
WHERE Continent is not null
GROUP by continent
ORDER BY TotalDeathsCount desc

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
WHERE Continent is null
GROUP by location
ORDER BY TotalDeathsCount desc

---- Showing continent with the highest death per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%malaysia%'
WHERE Continent is not null
GROUP by continent
ORDER BY TotalDeathsCount desc

---- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT *
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac
   ON dea.location = vac.location
   and dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3


-- USE CT
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--- Temp Table

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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT*
  FROM PercentPopulationVaccinated
