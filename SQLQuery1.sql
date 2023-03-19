select *
from ProtofolioProject..CovidDeaths$
where continent is not null 
order by 3,4

select *
from ProtofolioProject..['Covid-vaccination$']
order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from ProtofolioProject..CovidDeaths$
order by 1,2

-- total cases vs total deaths


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from ProtofolioProject..CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from ProtofolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--total cases vs population 
--shows what percenatge of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected 
from ProtofolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population 

select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentpopulationinfected
from ProtofolioProject..CovidDeaths$
--where location like '%states%'
group by population,location 
order by percentpopulationinfected desc


--showing countries with highest death count per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProtofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null 
group by location 
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT
-- showing the continents with the highest death count per population


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProtofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null 
group by continent 
order by TotalDeathCount desc


--Global numbers 
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100  as deathpercentage 
from ProtofolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
from ProtofolioProject..CovidDeaths$ dea
join ProtofolioProject..['Covid-vaccination$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 2,3 

--USE CTE

with popvsvac (continent,location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from ProtofolioProject..CovidDeaths$ dea
join ProtofolioProject..['Covid-vaccination$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
From popvsvac


--Temp Table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from ProtofolioProject..CovidDeaths$ dea
join ProtofolioProject..['Covid-vaccination$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
From #percentpopulationvaccinated


--creating view to store data for later visualizations 

create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from ProtofolioProject..CovidDeaths$ dea
join ProtofolioProject..['Covid-vaccination$'] vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 

select *
From percentpopulationvaccinated
