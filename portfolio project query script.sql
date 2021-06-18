use [Portfolio project]

select * from CovidDeaths
where continent is not null
order by 3,4 
--i use (where continent is not null ) because dataset contain continent wise rows too which creates discrepncies
--select * from covidVaccination
--order by 3,4

--selecting data that we are going to use

select location,date,total_cases,new_cases,Total_deaths,Population
from coviddeaths
where continent is not null
order by 1,2

--looking for total cases vs total deaths and fatality rate(which is calculated field) in INDIA

select location,date,total_cases,Total_deaths,(total_deaths/total_cases)*100 as Fatality_rate
from coviddeaths
where location like'%india%' and continent is not null
order by 1,2

--query to find total cases vs population of specific country (INDIA)
--percentage of population infected with covid

select location,date,total_cases,population,(total_cases/population)*100 as infection_percentage
from coviddeaths
where continent is not null
--and location like'%india%'
order by 1,2

--finding the countries havind hightest infection rate as compared to population

select location ,population, max(total_cases) as highest_infection_count,max((total_cases/population))*100 as 
percentage_population_infected
from coviddeaths
where continent is not null
group by location,population
order by percentage_population_infected desc

--query to find highest death count per poulation

select location , max(cast(total_deaths as int)) as maximum_deaths
from coviddeaths
where continent is not null
group by location
order by maximum_deaths desc



select location ,population, max(cast(total_deaths as int)) as maximum_deaths,max((total_deaths/population))*100 as 
percentage_population_died
from coviddeaths
where continent is not null
group by location,population
order by percentage_population_died desc

--i used cast clause in above query because i found total_deaths column is varchar so i converted into int to get correct output

-- query to find highest  death count by continent per population


select location , max(cast(total_deaths as int)) as maximum_deaths
from coviddeaths
where continent is  null
group by location
order by maximum_deaths desc

--total number of cases around the world

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage
from coviddeaths
where continent is not null
order by 1,2
 
--per day
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_percentage
from coviddeaths
where continent is not null
group by date
order by 1,2

--joining two table "coviddeath and "covidvaccination" for further exploration

select *
from coviddeaths D
join covidVaccination V
on d.location=v.location
and d.date=v.date


--total population vs total vaccinations

select d.continent,d.location,d.population,d.date,v.new_vaccinations
from coviddeaths D
join covidVaccination V
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3


--rolling total of new vaccinations(by usning partition by)

select d.continent,d.location,d.population,d.date,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date ) as rolling_total
from coviddeaths D
join covidVaccination V
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

-- Use of CTE

with popvsvac(continent,location,date, population,new_vaccinations,rolling_total)
as
(
select d.continent,d.location,d.population,d.date,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date ) as rolling_total
from coviddeaths D
join covidVaccination V
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3

)
-- to find rolling number vaccination percentage

select * ,(rolling_total/convert(int,population))*100 as rolling_total_percentage
from popvsvac 


--creating views to store date for visulatization in tableau

create view percentpopulationvaccinated as
select d.continent,d.location,d.population,d.date,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date ) as rolling_total
from coviddeaths D
join covidVaccination V
on d.location=v.location
and d.date=v.date
where d.continent is not null
--order by 2,3


select * 
from percentpopulationvaccinated