Select * from PortfolioProject.dbo.CovidDeaths order by 3,4
--select * from PortfolioProject.dbo.CovidVaccinations order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like 'netherlands' 
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population has got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where location like 'netherlands'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by location 
order by TotalDeathCount desc 

--Showing the continent with the highest death count
Select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by continent 
order by TotalDeathCount desc 

--Global Numbers everyday
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null 
group by date
order by 1,2

--Total infection & deaths
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null 
order by 1,2

--Looking at Total Population vs Vaccination 
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.[location] = vac.[location] and dea.date = vac.[date]
where dea.continent is not null
order by 2,3

-- Total vaccination per location
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.[location] = vac.[location] and dea.date = vac.[date]
where dea.continent is not null
order by 2,3

--Percentage of people vaccinated per country
--Use CTE
with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.[location] = vac.[location] and dea.date = vac.[date]
where dea.continent is not null)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageOfPeopleVaccinated
 from PopvsVac

 --Temp table
 Drop table if exists #PercentagePopulationVaccinated
 
 Create table #PercentagePopulationVaccinated 
 (continent nvarchar(50),
 location nvarchar(50),
 date date,
 population float, 
 new_vaccination float,
 RollingPeopleVaccinated float)  

Insert into #PercentagePopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.[location] = vac.[location] and dea.date = vac.[date]
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentagePopulationVaccinated
 from #PercentagePopulationVaccinated

 --Create view
 create view PercentagePopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.[location] = vac.[location] and dea.date = vac.[date]
where dea.continent is not null

Select * from PercentagePopulationVaccinated