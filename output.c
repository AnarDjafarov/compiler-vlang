#include <stdio.h>
#include <stdlib.h>
//implementations for helped functions
int PointCalc(int* vec1, int* vec2, int size, int scl)
{
	int result = 0;
	for (int i = 0; i < size; i++)
	{
		if(scl == -1)
		{
			result += vec1[i] * vec2[i];
		}
		else
		{
			result += vec1[i] * scl;
		}
	}
	return result;
}
int* AllocMemoryVec(int* firstVec, int* SecVec, int size)
{
	int* tempArr = malloc(sizeof(int)*size);//alocate_memory
		for(int i=0; i< size; i++)
		{
			tempArr[i] = firstVec[SecVec[i]];
		}
	return tempArr;
}

void printArray(int* vec, int size)
{
	printf("[");
	for(int i=0; i< size-1; i++)
	{
		printf("%d," ,vec[i]);//print every cell in array
	}
	printf("%d]\n", vec[size -1]);
}


void AssgnScalarArray(int* vec, int size, int scl)
{
	for(int i = 0; i < size; i++)
	{
		vec[i] = scl;//assigment the scalar for every cell in the arry
	}	
}


void AssgnArrayArray(int* dst, int* src, int size)
{
	for(int i=0; i< size; i++)
	{
		dst[i] = src[i];//assigment for evrey cell from src array to dst array 
	}
}

int* VectorsCalacs(int* vec1, char op, int* vec2, int size)
{
	int *temp = malloc(sizeof(int) * size);//alocate_memory for the answer
	switch (op)
	{
		case '+':// '+' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec1[i] + vec2[i];
			}
			break;

		case '-':// '-' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec1[i] - vec2[i];
			}
			break;

		case '*':// '*' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec1[i] * vec2[i];
			}
			break;

		case '/':// '/' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec1[i] / vec2[i];
			}
			break;
	}
	return temp;
}

int* VectorScalarCalacs(int* vec, char op, int scl, int size)
{
	int *temp = malloc(sizeof(int) * size);//alocate_memory for the answer
	switch (op)
	{
		case '+':// '+' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec[i] + scl;
			}
			break;

		case '-':// '-' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec[i] - scl;
			}
			break;

		case '*':// '*' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec[i] * scl;
			}
			break;

		case '/':// '/' case
			for (int i = 0; i < size; i++)
			{
				temp[i] = vec[i] / scl;
			}
			break;
	}
	return temp;
}

int main(void)
{
	int* temp;
	int x;
	int y;
	int i;
	int v1[6];
	int v2[6];
	int v3[6];
	x = 2;

	AssgnScalarArray(v1, 6, 2*x);
	int tempArr0[] = {1,1,2,2,3,3};

	AssgnArrayArray(v2, tempArr0, 6);
	printf("%d\n", PointCalc(v2,v1,6,-1) );
	y = v2[4];
	i = 0;
	for(int temp_index = 0; temp_index < y; temp_index++)
	{
	v1[i] = i;
	i = i+1;
	}
		temp = AllocMemoryVec(v2,v1,6);		printArray(temp, 6);
		free(temp);
	int tempArr1[] = {5,4,3,2,1,0};
		temp = AllocMemoryVec(v2,AllocMemoryVec(v1,tempArr1,6),6);		printArray(temp, 6);
		free(temp);

	int* tempDaynamicArr2 = VectorsCalacs(v1, '+', v2, 6);

	AssgnArrayArray(v3, tempDaynamicArr2, 6);
	int tempArr3[] = {2,1,0,2,2,0};
	printf("%d\n", v2[(PointCalc(v3,tempArr3,6,-1)/10)] );
	int a[3];
	int tempArr4[] = {10, 0, 20};

	AssgnArrayArray(a, tempArr4, 3);
	i = 0;
	for(int temp_index = 0; temp_index < 3; temp_index++)
	{
	int tempArr5[] = {1, 0, 0};
	if(PointCalc(tempArr5,a,3,-1))
	{
		printf("%d\n", i );
	printArray(a, 3);
	int tempArr6[] = {2, 0, 1};

	temp = AllocMemoryVec(a,tempArr6,3);
	AssgnArrayArray(a, temp , 3);

	free(temp);
	}
	i = i+1;
	}
	int z[4];

	AssgnScalarArray(z, 4, 10);
	int tempArr7[] = {2, 4, 6, 8};

	int* tempDaynamicArr8 = VectorsCalacs(z, '+', tempArr7, 4);

	int* tempDaynamicArr9 = VectorScalarCalacs(tempDaynamicArr8,'/', 2, 4);

	AssgnArrayArray(z, tempDaynamicArr9, 4);

	int* tempDaynamicArra = VectorScalarCalacs(z,'-', 3, 4);
	int tempArr13[] = {2, 3, 4, 5};

	int* tempDaynamicArrc = VectorsCalacs(tempDaynamicArra, '+', tempArr13, 4);

	AssgnArrayArray(z, tempDaynamicArrc, 4);
	printArray(z, 4);
	int tempArr15[] = {1,1,1,1};
	printf("%d\n", PointCalc(tempArr15,z,4,-1) );

	free(tempDaynamicArr2);
	free(tempDaynamicArr8);
	free(tempDaynamicArr9);
	free(tempDaynamicArra);
	free(tempDaynamicArrc);
	return 0;
}