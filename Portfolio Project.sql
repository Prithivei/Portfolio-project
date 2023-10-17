select *
from PorfolioProject..['Covid Deaths]
where continent is not null
order by 3,4

--select *
--from PorfolioProject..['Covid Vaccine]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..['Covid Deaths]
order by 1,2

-- Total cases vs Total Deaths (INDIA)

select location, date, total_cases, total_deaths, (convert(float, total_deaths)/nullif (convert (float, total_cases),0))*100 as DeathPercentage
from PorfolioProject..['Covid Deaths]
where location like '%India%'
order by 1,2

--Total Cases vs Population (Percentage of population got affected, INDIA)

select location, date, population, total_cases, (convert(float, total_cases)/nullif (convert (float, population),0))*100 as CasePercentage
from PorfolioProject..['Covid Deaths]
where location like '%India%'
order by 1,2

--Country with highest infection rate

select location, population, max(cast(total_cases as bigint)) as HighestInfection, MAX(total_cases/population)*100 as InfectionPercentage
from PorfolioProject..['Covid Deaths]
group by location,  population
order by InfectionPercentage desc

--country with highest death count

select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PorfolioProject..['Covid Deaths]
where continent is not null
group by location
order by TotalDeathCount desc


--seperating by continent 

select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
from PorfolioProject..['Covid Deaths]
where continent is not null
group by continent
order by TotalDeathCount desc

--select location, max(cast(total_deaths as bigint)) as TotalDeathCount
--from PorfolioProject..['Covid Deaths]
--where continent is null
--group by location
--order by TotalDeathCount desc


--Global Stat

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as bigint)) as Total_Deaths,
	sum(cast(new_deaths as bigint))/ sum(new_cases)*100 as DeathPercentage
from PorfolioProject..['Covid Deaths]
where continent is not null
order by 1,2

--select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as bigint)) as Total_Deaths,
--	sum(cast(new_deaths as bigint))/ sum(new_cases)*100 as DeathPercentage
--from PorfolioProject..['Covid Deaths]
--where continent is not null
--group by date
--order by 1,2

--set arithabort off;
--set ansi_warnings off;
--declare @num1 int;
--declare @num2 int;
--set @num1=12;
--set @num2=0;
--select @num1/@num2

--Joining both the Tables
select *
from PorfolioProject..['Covid Deaths] CD
join PorfolioProject..['Covid Vaccine] CV
	on CD.location = CV.location
	and CD.date = CV.date

--Total Population vs Vaccination

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingCount
--, (RollingCount/population)*100
from PorfolioProject..['Covid Deaths] CD
join PorfolioProject..['Covid Vaccine] CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
order by 2,3


--Using CTE

with TPvsVC (continent, location, date, population, new_vaccinations, RollingCount)
as
(
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingCount
from PorfolioProject..['Covid Deaths] CD
join PorfolioProject..['Covid Vaccine] CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
)

select *, (RollingCount/population)*100
from TPvsVC


--Temp Table

create table #perPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCount numeric
)

insert into #perPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingCount
--, (RollingCount/population)*100
from PorfolioProject..['Covid Deaths] CD
join PorfolioProject..['Covid Vaccine] CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null
--order by 2,3

select *, (RollingCount/population)*100
from #perPopulationVaccinated

--Data for visual

create view perPopulationVaccinated
as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, sum(convert(bigint, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingCount
--, (RollingCount/population)*100
from PorfolioProject..['Covid Deaths] CD
join PorfolioProject..['Covid Vaccine] CV
	on CD.location = CV.location
	and CD.date = CV.date
where CD.continent is not null


create view HighestInfectionRate
as
select location, population, max(cast(total_cases as bigint)) as HighestInfection, MAX(total_cases/population)*100 as InfectionPercentage
from PorfolioProject..['Covid Deaths]
group by location,  population
--order by InfectionPercentage desc

create view TotalDeathCount
as
select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PorfolioProject..['Covid Deaths]
where continent is not null
group by location
--order by TotalDeathCount desc

create view ContinentDeathCount
as
select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
from PorfolioProject..['Covid Deaths]
where continent is not null
group by continent
--order by TotalDeathCount desc

create view GlobalStat
as
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as bigint)) as Total_Deaths,
	sum(cast(new_deaths as bigint))/ sum(new_cases)*100 as DeathPercentage
from PorfolioProject..['Covid Deaths]
where continent is not null
--order by 1,2

