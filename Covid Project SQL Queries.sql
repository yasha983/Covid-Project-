select * 
From CovidProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--From CovidProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases,new_cases,total_deaths, population
From CovidProject..CovidDeaths
where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths
--shows likelihood of dying if you track covid in united states
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Showing the percertange of population got Covid
Select Location, date, total_cases, Population, (NULLIF(CONVERT(float, total_cases), 0)/ population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at contries with Highest Infection Rate compard to Population

Select Location, Population, Max(total_cases) as HightestInfectionCount, Max((NULLIF(CONVERT(float, total_cases), 0)/ population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%states%'
Group by Location,Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Break down by Continent
--showing continents with the highest deaths count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From CovidProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(NULLIF(Convert(float,vac.new_vaccinations),0)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2


--Use CTE

With PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(NULLIF(Convert(float,vac.new_vaccinations),0)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(NULLIF(Convert(float,vac.new_vaccinations),0)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
--where dea.continent is not null
--order by 1,2

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to store data for Later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(NULLIF(Convert(float,vac.new_vaccinations),0)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2

select * 
from PercentPopulationVaccinated