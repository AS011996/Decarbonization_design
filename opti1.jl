using Pkg
#add these packages if they aren't installed already
#Pkg.add("LinearAlgebra")
#Pkg.add("HiGHS")
#Pkg.add("XLSX")
using LinearAlgebra
using JuMP
using HiGHS
import XLSX


xfa=XLSX.readxlsx("unallocatedA.xlsx")
asheet=xfa["Sheet 1"];
A=asheet["B2:AY37"];
procnames=asheet["B1:AY1"]
xfb=XLSX.readxlsx("unallocatedB.xlsx")
bsheet=xfb["Sheet 1"];
B=bsheet["B2:AY12"]
xff=XLSX.readxlsx("Finaldemand.xlsx")
fsheet=xff["Sheet1"];
f=fsheet["B2:B37"]


print(size(A))
print(size(B))

fakeA=zeros(Float64, 36, 50)
for i in 1:36
    for j in 1:50
        fakeA[i,j]=convert(Float64, A[i,j])
    end
end


fakeB=zeros(Float64, 11, 50)
for i in 1:11
    for j in 1:50
        fakeB[i,j]=convert(Float64, B[i,j])
    end
end

fakef=zeros(Float64, 36)
for i in 1:36
    fakef[i]=convert(Float64, f[i, 1])
end

f=fakef

vector_model = Model(HiGHS.Optimizer)
@variable(vector_model,0 <= x[1:50] <= 1000) #row vector of scaling factors
#@constraint(vector_model, x[28] <= 6)
for i in 1:36
    @constraint(vector_model, dot(fakeA[i,:],x) >= f[i])
end
#@constraint(vector_model, dot(fakeA[24,:],x) == 0)
#demand of PET is zero
for i in 1:36 #stock of no product can be negative
    @constraint(vector_model, dot(fakeA[i,:],x) >= 0)
end
#@constraint(vector_model, fakeA[24,21]*x[21]+fakeA[24,50]*x[50] == 1)
@objective(vector_model, Min, dot(fakeB[3,:],x)+dot(fakeB[4,:],x)+dot(fakeB[9,:],x))
#print(vector_model)
optimize!(vector_model)
#@show termination_status(vector_model) #why the solver stopped
amts=value.(vector_model[:x]);
println("-------------------------------------")
println("-------------------------------------")
for i in 1:50
    print(procnames[i])
    print(":")
    print(amts[i])
    println()
end
