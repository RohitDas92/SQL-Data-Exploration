--select * from projectportfoliodb..CovidDeaths

--select * from projectportfoliodb..CovidVaccinations


select location, date, population,total_cases,total_deaths
from projectportfoliodb..CovidDeaths
order by 1,2

-- Finding Death Percentage to Total Cases
select location, date, population,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_pct
from projectportfoliodb..CovidDeaths
order by 1,2

-- Finding Death Percentage to Total Cases for India
select location, date, population,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_pct
from projectportfoliodb..CovidDeaths
where location like '%india%'
order by 1,2

--Looking total cases vs population for india
-- Shows what percentage of population got Covid
select location, date, population,total_cases,(total_cases/population)*100 as contracted_pct
from projectportfoliodb..CovidDeaths
where location like '%england%'
order by 1,2

--Looking at Countries with highest Infection Rate compared to population
select location, population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 as infected_pct
from projectportfoliodb..CovidDeaths
group by location, population
order by infected_pct desc


--Looking at countries with highest death count per location

select location, population,max(total_deaths) as highest_death_count, max((total_deaths/population))*100 as death_pct
from projectportfoliodb..CovidDeaths
where continent is not null
group by location, population
order by highest_death_count desc

-- Looking at continent with highest death rate
select location,max(population) as total_population,max(total_deaths) as highest_death_count, max((total_deaths/population))*100 as death_pct
from projectportfoliodb..CovidDeaths
where continent is null and location in ('Europe','North America','Asia','South America','Africa','Oceania')
group by location
order by death_pct desc

--Looking at global numbers
select location,max(population) as total_population,max(total_deaths) as highest_death_count, max((total_deaths/population))*100 as death_pct
from projectportfoliodb..CovidDeaths
where continent is null and location = 'World'
group by location
order by death_pct desc

--Joining CovidVaccination Table with CovidDeath Table

select *
from projectportfoliodb..CovidDeaths as CD
join projectportfoliodb..CovidVaccinations as CV
on CD.date = CV.date and CD.location = CV.location

--Looking at Total Population vs Vaccinations using Common Table Expression

with cte1 (continent,location,date,population,new_vaccinations,cumm_vaccination)
as (select CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	sum(CV.new_vaccinations) over(partition by CD.location order by CD.location, CD.date) as cumm_vaccination
from projectportfoliodb..CovidDeaths as CD
join projectportfoliodb..CovidVaccinations as CV
	on CD.date = CV.date 
	and CD.location = CV.location
where CD.continent is not null)
select *,(cumm_vaccination/population)*100 as vaccination_pct from cte1
order by 2,3

--Looking at Total Population vs Vaccinations using Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
cumm_vaccination numeric
)
Insert into #PercentagePopulationVaccinated
select CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	sum(CV.new_vaccinations) over(partition by CD.location order by CD.location, CD.date) as cumm_vaccination
from projectportfoliodb..CovidDeaths as CD
join projectportfoliodb..CovidVaccinations as CV
	on CD.date = CV.date 
	and CD.location = CV.location
--where CD.continent is not null

select *,(cumm_vaccination/population)*100 as vaccination_pct 
from #PercentagePopulationVaccinated
where location like '%world%'


--Creating View to store data for later visulization

create view PopulationVaccinatedView as 
select CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	sum(CV.new_vaccinations) over(partition by CD.location order by CD.location, CD.date) as cumm_vaccination
from projectportfoliodb..CovidDeaths as CD
join projectportfoliodb..CovidVaccinations as CV
	on CD.date = CV.date 
	and CD.location = CV.location
where CD.continent is not null


select * from PopulationVaccinatedView
