select *
from PortfolioProject..CovidDeaths

select *
from PortfolioProject..CovidVaccinations

--select data yang kita perlukan
select continent, location, date, total_cases, new_cases, total_deaths, population  
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- mencari presentase kematian
-- mencari presentase kematian disetiap negara

select continent, location, date, total_cases, total_deaths
,(total_deaths/total_cases)*100 as deaths_percentage
from PortfolioProject..CovidDeaths
--where location like '%indo%'
where continent is not null
order by 1,2,3

-- mencari negara dengan presentasi infeksi tertinggi dibandingkan populasinya
select continent, location, population, max(total_cases) as HighestInfectionCount
, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by continent, location, population
order by 1,2,3

--Countries with Highest Death Count per Population
select location, max(cast(total_deaths as int)) as highestDeathCount, population
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%indonesia%'
group by continent, location, population
order by highestDeathCount desc
-- total_deaths can't count cause nvarchar must change to int
-- dalam kasus ini order by tidak bisa dipakai menjadi 2 column yang tereksekusi 
--hanyalah function yang pertama

-- urutkan highestdeathcount besar ke kecil
-- Showing contintents with the highest death count per population
select continent, max(cast(total_deaths as int)) as highestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
and total_deaths is not null
--and location like '%indo%'
group by continent
order by highestDeathCount desc

-- mencari presentasi kematian disetiap negara
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths
, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
where continent is not null

-- looking for rolling people vacinatted
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2
--perbedaan convert dan cast, convert bisa mengcovert banyak tipe data sekalipun itu date

with popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	 on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingVaccinated
from popvsVac

drop table if exists #PercentPopulationVaccinated
-- create a temp table
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric, 
RollingPeopleVaccinated numeric
)

-- inserting analyst data into temp table
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--membuat view 
create view PercentPopulationVaccinated as	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by 
dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


 