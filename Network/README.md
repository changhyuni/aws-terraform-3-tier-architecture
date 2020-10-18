# Network

VPC를 만들고 퍼블릭 서브넷에 NAT & Bastion 역할을하는 인스턴스를 생성합니다. 서브넷은 고가용성이 보장됩니다. 각 보안그룹 세팅으로 Bastion은 프라이빗 서브넷에 위치하는 인스턴스로 접근가능합니다. Tomcat 과 Nginx 의 기본포트인 80번과 8080번만 사용합니다.

[사용된 리소스](https://www.notion.so/2fd23ea9acd44a10bba8cd344512fe1f)

[Security Group 설정](https://www.notion.so/341532b8a5854e7f9777f2fd45a5f9da)

- Bastion SG : 모든 IP 에서 SSH 접속 할 수 있게 22번 개방
- PUBLIC-ELB-SG :  모든IP 포트 에서 HTTP 접속 할 수 있게 80번 포트 개방
- WEB-SG : 모든IP 포트에서 접근가능하게 80번포트를 개방한다.
- PRIVATE-ELB-SG: WEB-SG을 통과한 트래픽에 대해서만 내부로 들어올 수 있도록 8080 개방
- WAS-SG **:** PRIVATE-ELB-SG을 통과한 트래픽에 대해서만 Application 으로 들어올 수 있도록 8080 개방
- DB-SG: PRIVATE-ELB-SG을 통과한 트래픽에 대해서만 RDS로 들어올 수 있도록 5432 개방
