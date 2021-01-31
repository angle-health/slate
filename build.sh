# this is used to build and send docs

bundle exec middleman build --clean
zip -r build.zip build/
scp -i ~/AWS_Installation/angle.pem build.zip ec2-user@ec2-18-191-162-28.us-east-2.compute.amazonaws.com:/home/bitnami/
rm -rf build.zip
