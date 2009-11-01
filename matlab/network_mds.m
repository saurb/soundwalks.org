clc;
clear all;
close all;

distances = csvread('../data/mds/distances.csv');
ids = csvread('../data/mds/ids.csv');

locations = cmdscale(distances);

for i = 1:length(locations)
    fprintf('%d,%f,%f\n', ids(i), locations(i, 1), locations(i, 2));
end
