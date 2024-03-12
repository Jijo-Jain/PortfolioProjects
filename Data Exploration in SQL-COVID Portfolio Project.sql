--Select Data that we are going to use

--select * from PortfolioProject.dbo.Covid_Deaths
--order by 3,4
--select * from PortfolioProject.dbo.Covid_Vaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.Covid_Deaths
order by 1,2

--Looking at the Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/Cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject.dbo.Covid_Deaths
where location = 'India'
order by 1,2

--Looking at total cases vs population
--Shows what% of populations got covid
Select location, date,  Population, total_cases, (cast(total_cases as float)/Cast(population as float))*100 as PecrentPopulationInfected
from PortfolioProject.dbo.Covid_Deaths
--where location = 'India'
order by 1,2 

--Looking at Countries with highest Infection rate compared to population
Select location, Population, Max(total_cases) as HighestInfectionCount, Max((cast(total_cases as float)/Cast(population as float)))*100 as PecrentPopulationInfected
from PortfolioProject.dbo.Covid_Deaths
--where location = 'India'
Group By location, population
order by 4 desc

--Showing Countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.Covid_Deaths
--where location = 'India'
Where continent is not null
Group By location
Order by 2 desc

--Showing Continent with highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.Covid_Deaths
--where location = 'India'
Where continent is not null
Group By continent
Order by 2 desc

--GLobal Numbers
SELECT  
       SUM(new_cases) as Total_cases, 
       SUM(new_deaths) as Total_Deaths,
       SUM(new_deaths) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.Covid_Deaths
--where location = 'India'
Where continent is null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevacinated
-- (Rollingpeoplevacinated/population) * 100
from Covid_Deaths dea
Join Covid_Vaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevacinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevacinated
-- (Rollingpeoplevacinated/population) * 100
from Covid_Deaths dea
Join Covid_Vaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevacinated/population) * 100
from PopvsVac

--Using Temp Table

Drop table if exists #PercentPopulationVacinated
Create table #PercentPopulationVacinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccination bigint,
Rollingpeoplevacinated bigint)

Insert into #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevacinated
from Covid_Deaths dea
Join Covid_Vaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
order by 2,3

select *, (Rollingpeoplevacinated/population) * 100
from #PercentPopulationVacinated



--Creating View to store data for later visulization

Create view PercentPopulationVacinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevacinated
from Covid_Deaths dea
Join Covid_Vaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

