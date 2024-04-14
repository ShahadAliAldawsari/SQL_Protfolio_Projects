/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Select Data that we are going to be starting with
select continent, location, date, new_cases, total_cases, new_deaths, total_deaths 
from CovidDeaths
order by date


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, round(max(total_deaths)/max(total_cases)*100,3) as death_rate
from CovidDeaths
where continent is not null --to show cantries only not continents (to prevent redundancy)
group by location
order by death_rate DESC


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location, round(max(total_cases)/max(population)*100,3) as infection_rate_VS_countries
from CovidDeaths
where continent is not null --to show cantries only not continents (to prevent redundancy)
group by location
order by infection_rate_VS_countries DESC


-- Countries with Highest Infection Rate compared to Population
select location, round(max(total_cases)/max(population)*100,3) as infection_rate_VS_continents
from CovidDeaths
where continent is null --to show continents only not cantries (to prevent redundancy)
group by location
order by infection_rate_VS_continents DESC


-- Countries with Highest Death Count per Population
select location, round(max(total_deaths)/max(population)*100,3) as death_rate_VS_population
from CovidDeaths
where continent is not null --to show cantries only not continents (to prevent redundancy)
group by location
order by death_rate_VS_population DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
select location, max(cast(total_deaths as int)) as max_death, --(cast) used to convert total_deaths column data type from char to int
max(population) as max_population
from CovidDeaths
where continent is not null --to show cantries only not continents (to prevent redundancy)
group by location
order by max_death DESC


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
round(SUM(cast(new_deaths as int))/SUM(New_Cases)*100, 3) as DeathPercentage
From CovidDeaths
where continent is not null 
order by total_cases, total_deaths


-- Total Population vs Vaccinations
-- Shows number of Population that has recieved at least one Covid Vaccine
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.population, CovidDeaths.date, 
CovidVaccinations.new_vaccinations,
sum(convert(int, CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rolling_population_vaccinated
from CovidDeaths join CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location 
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null


-- Using CTE to perform Calculation on Partition By in previous query
with Population_Vaccination_cte (continent, location, population, date, new_vaccinations, rolling_population_vaccinated)
as (select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.population, CovidDeaths.date, 
	CovidVaccinations.new_vaccinations,
	sum(convert(int, CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rolling_population_vaccinated
	from CovidDeaths join CovidVaccinations
	on CovidDeaths.location=CovidVaccinations.location 
	and CovidDeaths.date=CovidVaccinations.date
	where CovidDeaths.continent is not null)
select *, round((rolling_population_vaccinated/population)*100, 3) as Vaccinated_Population_Rate
from Population_Vaccination_cte


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #Population_Vaccination_tmp
create table #Population_Vaccination_tmp
(
	continent varchar(255),
	location varchar(255),
	population int,
	date datetime,
	new_vaccinations int,
	rolling_population_vaccinated int
)
insert into #Population_Vaccination_tmp
	select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.population, CovidDeaths.date, 
	CovidVaccinations.new_vaccinations,
	sum(convert(int, CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rolling_population_vaccinated
	from CovidDeaths join CovidVaccinations
	on CovidDeaths.location=CovidVaccinations.location 
	and CovidDeaths.date=CovidVaccinations.date
	where CovidDeaths.continent is not null

select *, round((rolling_population_vaccinated/population)*100, 3) as Vaccinated_Population_Rate
from #Population_Vaccination_tmp


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
	select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.population, CovidDeaths.date, 
	CovidVaccinations.new_vaccinations,
	sum(convert(int, CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.date) as rolling_population_vaccinated
	from CovidDeaths join CovidVaccinations
	on CovidDeaths.location=CovidVaccinations.location 
	and CovidDeaths.date=CovidVaccinations.date
	where CovidDeaths.continent is not null

select * from PercentPopulationVaccinated
