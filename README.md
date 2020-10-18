
# AWS 3-Tier Architecture in Terraform


### Overview

애플리케이션 및 데이터 계층으로 구성된 AWS 3-Tier 아키텍쳐를 제공합니다. 사용자는 Route53 를 통해 전달된 다음 ALB를 거쳐 Nginx 웹 서버로 연결되고 Auto Scaling 을 제공합니다. 웹서버 계층에 인스턴스는 내부 ALB를 통해 애플리케이션 계층과 통신하고 Auto Scaling을 제공합니다. 애플리케이션 계층은 EC2위에 Tomcat Server가 존재하고 애플리케이션 계층만이 데이터 계층의 RDS와 통신할 수 있습니다. 각 계층간 통신은 보안 그룹을 사용하여 계층에 필요한 기능에 엔드 포인트에 연결할 수 있습니다.  

- [Network](https://github.com/changhyuni/AWS-3TIER/tree/main/Network)
- [Web & WAS](https://github.com/changhyuni/AWS-3TIER/tree/main/WEB%20%26%20WAS)
- [Database](https://github.com/changhyuni/AWS-3TIER/tree/main/Database)

### Architecture
![ex_screenshot](./architecture.png)
### How to Terraform Deploy

---

사전설정 : 

- aws cli를 통해 터미널에서 Credentials 설정을 해준뒤                                                                                        git repository 를 clone 합니다.

```bash
$ git clone https://github.com/changhyuni/AWS-3TIER
```

- 클론된 디렉토리에서 "terraform init" 후 모듈에 사용할 값을 입력합니다.

```bash
$ terraform init
```

- 리소스 배포시작 :

```bash
$ terraform apply
```

- 리소스 삭제 :

```bash
$ terraform destroy
```
### Note
* "autoscaler" 모듈에 입력되는 AMI 값은 제공되는 [packer](https://github.com/changhyuni/AWS-3TIER/tree/main/WEB%20%26%20WAS/packer) 로 만들어야합니다.

### How to Test

- 호스트에서 웹 계층에 외부로드밸런서로 "curl" 를 실행합니다. 웹 브라우저를를 테스팅합니다. 웹 브라우저를 이용하여 외부 ALB로 접속합니다.
- Bastion Host 에서 SSH를 통해 웹 계층에있는 인스턴스에 접속하여 "curl" 로 내부로드 밸런서를 확인합니다.
- Bastion Host 에서 SSH 로 애플리케이션 계층에 인스턴스로 접속합니다. 애플리케이션 인스턴스에서 RDS 인스턴스 (Port 3306) 로 'telnet'을 연결하여 데이터베이스에 연결합니다.
- Apache Bench를 사용해 웹서버의 DNS나 외부 로드벨런서로 HTTP Request를 보내 오토스케일링 여부를 확인합니다.

### Open Sources

- Terraform
- Packer
- Terraform Cloud
- git
- Apache Bench

### References

[https://github.com/terraform-aws-modules](https://github.com/terraform-aws-modules)

[https://github.com/tellisnz/terraform-aws](https://github.com/tellisnz/terraform-aws)

[https://medium.com/the-andela-way/designing-a-three-tier-architecture-in-aws-e5c24671f124](https://medium.com/the-andela-way/designing-a-three-tier-architecture-in-aws-e5c24671f124)

[https://blog.2dal.com/2017/10/29/aws-bastion-with-terraform-modules/](https://blog.2dal.com/2017/10/29/aws-bastion-with-terraform-modules/)

---
