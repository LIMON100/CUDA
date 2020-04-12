#include<iostream>
#include<cuda.h>
#include<conio.h>
#include<cuda_runtime.h>
#include<device_launch_parameter.h>
#include "FindClosestCPU.h"

using namespace std;

int main()
{
	const int count = 1000;

	int* indexofClosest = new int[count];
	float* points = new float[count];

	for (int i = 0; i < count; i++) {

		points[i].x = (float)((rand() % 10000) - 5000);
		points[i].y = (float)((rand() % 10000) - 5000);
		points[i].z = (float)((rand() % 10000) - 5000);

	}

	long fastest = 1000000;

	for (int q = 0; q < 20; q++) {
		long startTime = clock();

		FindClosestCPU(points, indexofClosest, count);

		long finishTime = clock();

		std::cout << "Run " << q << " took " << (finishTime - startTime) << std::endl;

		if ((finishTime - startTime) < fastest) {
			fastest = (finishTime - startTime);
		}
	}

	std::cout << "Final result:" << std::endl;

	for (int i = 0; i < 10; i++) {
		std::cout << i << "." << indexofClosest[i] << std::endl;
	}

	delete[] indexofClosest;
	delete[] points;

	getch();

	return 0;
}