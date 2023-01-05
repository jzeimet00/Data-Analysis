
--Deaths Table
Select *
From [Portfolio Project]..CovidDeaths$
order by location,date

--Vaccinations Table
Select * FROM [Portfolio Project]..CovidVaccinations$
Order by location,date

--Countries with the Most Covid Deaths and Number of Cases
Select location, Sum(cast(new_deaths as bigint)) as TotalDeaths, Sum(cast(new_cases as bigint)) as TotalCases
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeaths Desc


--Safest Countries with highest case to death ratio
With CTE (Location, TotalCases, TotalDeaths) AS
(
Select location, Sum(cast(new_cases as bigint)) as TotalCases,(Sum(cast(new_deaths as bigint))) as TotalDeaths
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by location
)
Select *, Convert(numeric,(TotalCases/TotalDeaths)) As Case_to_Death_Ratio
From CTE
Order by Case_to_Death_Ratio Desc

--Countries with the highest death rates per case
With NotSafe (Location, TotalCases, TotalDeaths) AS
(
Select location, Sum(cast(new_cases as bigint)) as TotalCases,(Sum(cast(new_deaths as bigint))) as TotalDeaths
From [Portfolio Project]..CovidDeaths$
Where continent is not null
Group by location
)
Select *, CAST(TotalDeaths as float)/CAST(TotalCases as float)*100 AS DeathsperCasePercent
From NotSafe
Where TotalCases IS Not Null And TotalDeaths IS Not Null
Order by DeathsperCasePercent Desc


--Shows when you had the highest likelihood of dying if you got covid in the United States
Select location, date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
From [Portfolio Project]..CovidDeaths$
Where location ='United States'  AND continent is not null and total_cases >1000
ORDER by Death_Percentage DESC

---Shows the dates with the most covid per population percentage
Select location, date,total_cases,population, (total_cases/population)*100 AS Cases_Population_Percent
From [Portfolio Project]..CovidDeaths$
Where location = 'United States'   AND total_cases is not null AND continent is not null
ORDER by Cases_Population_Percent DESC

--Looking at Countries with Highest Infection Rates
Select location,population, MAX(total_cases) as HighestCaseCount, MAX((total_cases)/population)*100 AS Covid_Population_Percent
From [Portfolio Project]..CovidDeaths$
WHERE population IS NOT NULL AND continent is not null
GROUP BY location,population
ORDER by Covid_Population_Percent DESC


---Death Count by Continent
Select continent, MAX(cast(total_deaths as bigint)) AS Deaths
From [Portfolio Project]..CovidDeaths$
Where continent is not null And continent != 'Oceania'
GROUP BY continent
Order by Deaths Desc


--Join Covid Deaths and Covid Vaccinations Tables
Select *
From [Portfolio Project]..CovidVaccinations$ vac
JOIN [Portfolio Project]..CovidDeaths$ dea
	On vac.location = dea.location
	and vac.date = dea.date

--Most vaccinations by country
Select dea.location, dea.population, SUM(cast(vac.new_vaccinations as bigint)) as Vaccinations, (SUM(cast(vac.new_vaccinations as bigint))/population) AS Vaccinations_per_person
From [Portfolio Project]..CovidVaccinations$ vac
JOIN [Portfolio Project]..CovidDeaths$ dea
	On vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
Group by dea.location,dea.population
order by Vaccinations_per_person DESC

--Most tests by country
Select dea.location, dea.population, SUM(cast(vac.new_tests as bigint)) as New_Tests, (SUM(cast(vac.new_tests as bigint))/population) AS Tests_per_person
From [Portfolio Project]..CovidVaccinations$ vac
JOIN [Portfolio Project]..CovidDeaths$ dea
	On vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null
Group by dea.location,dea.population
order by Tests_per_person DESC


--Rolling Count of Vaccinations in United States 
--Shows timeline of when people started getting vaccinated for Covid-19
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingCountVaccinations
From [Portfolio Project]..CovidVaccinations$ vac
JOIN [Portfolio Project]..CovidDeaths$ dea
	On vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null And dea.location= 'United States'
order by location,date

--Rolling Count of Tests in United States 
--Shows timeline of when people started getting tested for Covid-19
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
SUM(CONVERT(bigint,vac.new_tests)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingCountTests
From [Portfolio Project]..CovidVaccinations$ vac
JOIN [Portfolio Project]..CovidDeaths$ dea
	On vac.location = dea.location
	and vac.date = dea.date
Where dea.continent is not null And dea.location= 'United States'
order by location,date







